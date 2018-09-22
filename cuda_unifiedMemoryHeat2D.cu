#include<iostream>
#include<iomanip>
#include<fstream>
#include<vector>
#include<utility>
#include<chrono>

#include<cstdlib>
#include<cstdio>
#include<cmath>

#define pi 4.0*atan(1.0)
#define blockDim_x 128
#define blockDim_y 8

using namespace std;
using namespace std::chrono;

/*
__global__ void add(int N, float *x, float *y){

  int index = blockIdx.x*blockDim.x + threadIdx.x;
  int stride = blockDim.x*gridDim.x;
  for(int i=index; i<N; i+=stride){
    y[i] = x[i] + y[i];
  }
}
*/

//monolithic kernel
__global__  void  cuda_diffusion2d_0
(
   float    *f,         /* dependent variable                        */
   float    *fn,        /* dependent variable                        */
   int      nx,         /* grid number in the x-direction            */
   int      ny,         /* grid number in the x-direction            */
   float    c0,         /* coefficient no.0                          */
   float    c1,         /* coefficient no.1                          */
   float    c2          /* coefficient no.2                          */
)
{
   int    j,    jx,   jy;
   float  fcc,  fce,  fcw,  fcs,  fcn;

   jy = blockDim.y*blockIdx.y + threadIdx.y;
   jx = blockDim.x*blockIdx.x + threadIdx.x;

   //Dirichilet BC
if(jx > 0  && jx < nx-1){
if(jy > 0 && jy < ny-1){
   j = nx*jy + jx;
   fcc = f[j];
   fcw = f[j - 1];
   fce = f[j+1];
   fcs = f[j-nx];
   fcn = f[j+nx];

   fn[j] = c0*(fce + fcw)
         + c1*(fcn + fcs)
         + c2*fcc;
 }
 }
   
}

int main()
{

  int nx;
  int ny;
  cout<<"Enter nx, ny "<<endl;
  cin>>nx;
  cin>>ny;
  
  float dx = 1.0/(float)(nx-1);
  float dy = 1.0/(float)(ny-1);
  float dt = 0.01*(dx*dx);

  //allocate arrays and initial condition
  //using unified memory
  float *Told, *Tnew;
  cudaMallocManaged(&Told,(nx*ny)*sizeof(float));
  cudaMallocManaged(&Tnew,(nx*ny)*sizeof(float));

  for(int i=0; i<nx; i++){
    for(int j=0; j<ny; j++){
      int id = i*ny + j;
      Told[id] = sin((float)i*dx*pi)*sin((float)j*dy*pi);
      Tnew[id] = 0.0f;
    }
  }

  float kappa = 1.0;
  float c0 = kappa*dt/(dx*dx),
        c1 = kappa*dt/(dy*dy),
        c2 = 1.0 - 2.0*(c0 + c1);
  
  int gridX = nx/blockDim_x;
  int gridY = ny/blockDim_y;

  //CUDA specific object type
  dim3 grid(gridX,gridY,1), threads(blockDim_x,blockDim_y,1);

  //time loop
  int iter = 0;
  int itermax = 20000;
  double operation = 0.0;

  high_resolution_clock::time_point t1 =
    high_resolution_clock::now();
  
  do{
  
  //run kernel on gpu
  cuda_diffusion2d_0<<<grid,threads>>>(Told,Tnew,nx,ny,c0,c1,c2);
  swap(Told,Tnew);

  if(iter%1000 == 0) cout<<"Step : "<<iter<<endl;

  operation += 7.0*(double)ny *(double)nx;
  iter +=1;
    
  }while(iter<itermax+1);

  high_resolution_clock::time_point t2 =
    high_resolution_clock::now();

  duration<double> elapsed_time = duration_cast<duration<double> >(t2-t1);

  cout<<"Operations : "<<operation<<endl;
  cout<<"Elapsed time : "<<elapsed_time.count()<<" secs."<<endl;
  double flops = operation /(elapsed_time.count()*1e9);
  cout<<"Performance : "<<flops<<" GFLOPS"<<endl;
  
  //synchronize host-gpu memory for file output
  cudaDeviceSynchronize();
  
  //ouput result to .csv file
  ofstream fileOut;
  fileOut.open("cudaUnifiedMemHeatEq.csv");
  fileOut<<"x,y,z,T\n";
  for(int i=0; i<nx; ++i){
    for(int j=0; j<ny; ++j){
      int id = i*ny + j;
      float xg = (float)i*dx;
      float yg = (float)j*dy;
      fileOut<<setprecision(8);
      fileOut<<fixed;
      fileOut<<xg<<","
	     <<yg<<","
	     <<Told[id]<<","
	     <<Told[id]<<"\n";
    }
  }
  fileOut.close();


  //free memory
  cudaFree(Told);
  cudaFree(Tnew);

  return 0;
  
}
