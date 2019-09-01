#include <fstream>
#include <string>
#include<cstdlib>
#include<iostream>

#include<sys/stat.h>

#define FALSE 0
#define TRUE 1

using namespace std;

bool IsPathExist(const std::string &s)
{
  struct stat buffer;
  return (stat (s.c_str(), &buffer) == 0);
}

int main()
{

  
  /*
  string ans;
  char *mycmd = "mkdir dum";
  cout<<mycmd<<endl;
  const int dir_err = system(mycmd);
  if(dir_err == -1){
    cout<<"Error in creating directory!\n";
  }
  */

  string mydir ="dum";
  string mypath = "./dum/";
  string myfile = "file.txt";

  cout<<mypath+myfile<<endl;
  
  bool test = IsPathExist(mypath);

  cout<<test<<endl; //0-false; 1-true

  if(test==TRUE){
    string mypath2 = mypath+myfile;
    ofstream file(mypath2);
    string data("Take that!\n");
    file << data;
    file.close();
  }
  else{
    string mycmd = "mkdir "+mydir;
    const char *c = mycmd.c_str();
      const int dir_err = system(c);
  if(dir_err == -1){
    cout<<"Error in creating directory!\n";
  }

  string mypath2 = mypath+myfile;
    ofstream file(mypath2);
    string data("Take that!\n");
    file << data;
    file.close();
    
  };
  
  //   const char *path="./dum/file.txt";
// std::ofstream file(path); //open in constructor

  /*
  string mypath2 = "./dum/file.txt";
 std::ofstream file(mypath2); //open in constructor
 std::string data("data to write to file\n");
    file << data;
    file << "I am tired of trying!\n";
  */
    
}//file destructor

