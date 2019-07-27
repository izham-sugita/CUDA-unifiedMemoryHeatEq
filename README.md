This is a simple example of using unified memory for CUDA programming. All the boilerplates
code for memory allocation and copy are hidden inside cudaMallocManaged() function.
This approach is possible easier to implement compare to OpenACC directives.

2017/7/27
Modified the while-loop for a more concise calculation and display. Removing the need for 
if-branch to check for steps.
