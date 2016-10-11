
struct FILE {

}

struct proc {
   void** address_space; //list of address spaces
   int* address_space_size; //size of each address space
   int address_space_count; //address_space_size = malloc(sizeof(int)*address_space_count);

   void* exec; //code
   u64_t exec_size;

   void* prog_data;
   u64_t prog_data_size;

   void* stack;
   u64_t stack_size;

   //u64 regs1, regs2, regs3, regs4, regs5;
   u64 regs[256];
   u64 program_counter;
   u64 stack_pointer;

   //TODO: some hardware registers
   //TODO: other info to run program;

   FILE* files_pids;
   u64 num_files;
}
