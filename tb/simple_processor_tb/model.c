#include "stdio.h"
#include "stdint.h"
#include "stdbool.h"
#include "math.h"

#define ADDI  (0b0001)
#define ADD   (0b0011)
#define SUB   (0b1011)
#define AND   (0b0101)
#define OR    (0b1101)
#define XOR   (0b1111)
#define NOT   (0b0111)
#define LOAD  (0b0010)
#define STORE (0b1010)
#define SLL   (0b0110)
#define SLR   (0b0100)
#define SLLI  (0b1110)
#define SLRI  (0b1100)

uint8_t  MEM [(1024*1024*1024)];
uint32_t PC;
uint32_t GPR [8];

int8_t  RD;
int8_t  RS1;
int8_t  RS2;
int32_t IMM;
int8_t  OP;

bool     DMEM_OP;
bool     DMEM_WE;
uint32_t DMEM_ADDR;
uint32_t DMEM_DATA;

void model_write(uint32_t addr, uint8_t data) {
  MEM[addr] = data;
}

uint8_t model_read(uint32_t addr) {
  return MEM[addr];
}

void model_set_PC(uint32_t addr) {
  PC = addr;
}

uint32_t model_get_PC() {
  return PC;
}

void model_set_GPR(uint8_t addr, uint32_t data) {
  GPR[addr] = data;
}

uint32_t model_get_GPR(uint8_t addr) {
  return GPR[addr];
}

void model_dis_asm(int instr) {
  RD  = ((instr & 0xE000)>>13);
  RS1 = ((instr & 0x1C00)>>10);
  RS2 = ((instr & 0x0380)>> 7);
  IMM = ((instr & 0x03F0)>> 4);
  if (IMM > 31) IMM = IMM - 64;
  OP  = ((instr & 0x000F)>>00);
  switch (OP) {
    case ADDI  : printf("\033[1;32m0x%08x ADDI  X%0d X%0d %0d\033[0m\n" , PC, RD, RS1, IMM); break;
    case ADD   : printf("\033[1;32m0x%08x ADD   X%0d X%0d X%0d\033[0m\n", PC, RD, RS1, RS2); break;
    case SUB   : printf("\033[1;32m0x%08x SUB   X%0d X%0d X%0d\033[0m\n", PC, RD, RS1, RS2); break;
    case AND   : printf("\033[1;32m0x%08x AND   X%0d X%0d X%0d\033[0m\n", PC, RD, RS1, RS2); break;
    case OR    : printf("\033[1;32m0x%08x OR    X%0d X%0d X%0d\033[0m\n", PC, RD, RS1, RS2); break;
    case XOR   : printf("\033[1;32m0x%08x XOR   X%0d X%0d X%0d\033[0m\n", PC, RD, RS1, RS2); break;
    case NOT   : printf("\033[1;32m0x%08x NOT   X%0d X%0d\033[0m\n",      PC, RD, RS1);      break;
    case LOAD  : printf("\033[1;32m0x%08x LOAD  X%0d X%0d\033[0m\n",      PC, RD, RS1);      break;
    case STORE : printf("\033[1;32m0x%08x STORE X%0d X%0d\033[0m\n",      PC,     RS2, RS1); break;
    case SLL   : printf("\033[1;32m0x%08x SLL   X%0d X%0d X%0d\033[0m\n", PC, RD, RS1, RS2); break;
    case SLR   : printf("\033[1;32m0x%08x SLR   X%0d X%0d X%0d\033[0m\n", PC, RD, RS1, RS2); break;
    case SLLI  : printf("\033[1;32m0x%08x SLLI  X%0d X%0d %0d\033[0m\n" , PC, RD, RS1, IMM); break;
    case SLRI  : printf("\033[1;32m0x%08x SLRI  X%0d X%0d %0d\033[0m\n" , PC, RD, RS1, IMM); break;
    default    : printf("\033[1;32m0x%08x INVALID\033[0m\n");                                break;
  }
}

int read_word(uint32_t addr) {
  uint32_t data;
  data =        MEM[addr+3];
  data = data << 8;
  data = data | MEM[addr+2];
  data = data << 8;
  data = data | MEM[addr+1];
  data = data << 8;
  data = data | MEM[addr+0];
  DMEM_OP = 1;
  DMEM_WE = 0;
  DMEM_ADDR = addr;
  DMEM_DATA = data;
  return data;
}

void write_word(uint32_t addr, uint32_t data) {
  if (addr != 0) {
    MEM[addr+3] = ((data & 0xFF000000) >> 24);
    MEM[addr+2] = ((data & 0x00FF0000) >> 16);
    MEM[addr+1] = ((data & 0x0000FF00) >>  8);
    MEM[addr+0] = ((data & 0x000000FF) >>  0);
    DMEM_OP = 1;
    DMEM_WE = 1;
    DMEM_ADDR = addr;
    DMEM_DATA = data;
  }
}

bool model_is_dmem_op() {
  return DMEM_OP;
}

bool model_is_dmem_we() {
  return DMEM_WE;
}

uint32_t model_dmem_addr() {
  return DMEM_ADDR;
}

uint32_t model_dmem_data() {
  return DMEM_DATA;
}

void model_step() {
  int instr;
  instr = (MEM[PC+1] << 8) | (MEM[PC]);
  model_dis_asm(instr);
  DMEM_OP = 0;
  switch (OP) {
    case ADDI  : GPR[RD] = GPR[RS1] + IMM;        GPR[0]=0; break;
    case ADD   : GPR[RD] = GPR[RS1] + GPR[RS2];   GPR[0]=0; break;
    case SUB   : GPR[RD] = GPR[RS1] - GPR[RS2];   GPR[0]=0; break;
    case AND   : GPR[RD] = GPR[RS1] & GPR[RS2];   GPR[0]=0; break;
    case OR    : GPR[RD] = GPR[RS1] | GPR[RS2];   GPR[0]=0; break;
    case XOR   : GPR[RD] = GPR[RS1] ^ GPR[RS2];   GPR[0]=0; break;
    case NOT   : GPR[RD] = -1 - GPR[RS1];         GPR[0]=0; break;
    case LOAD  : GPR[RD] = read_word(GPR[RS1]);   GPR[0]=0; break;
    case STORE : write_word (GPR[RS1], GPR[RS2]); GPR[0]=0; break;
    case SLL   : GPR[RD] = GPR[RS1] << GPR[RS2];  GPR[0]=0; break;
    case SLR   : GPR[RD] = GPR[RS1] >> GPR[RS2];  GPR[0]=0; break;
    case SLLI  : GPR[RD] = GPR[RS1] << IMM;       GPR[0]=0; break;
    case SLRI  : GPR[RD] = GPR[RS1] >> IMM;       GPR[0]=0; break;
    default    : printf("\033[1;31mERROR\033[0m\n");        break;
  }
  PC = PC + 2;
}
