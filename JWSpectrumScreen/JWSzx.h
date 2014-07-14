/*
 *  JWSzx.h
 *  JWSpectrumScreen
 *
 *  Created by James Weatherley on 24/11/2007.
 *  Copyright 2007 James Weatherley. All rights reserved.
 *
 */

#import <sys/types.h>

// Machine identifiers
#define ZXSTMID_16K          0
#define ZXSTMID_48K          1
#define ZXSTMID_128K         2
#define ZXSTMID_PLUS2        3
#define ZXSTMID_PLUS2A       4
#define ZXSTMID_PLUS3        5
#define ZXSTMID_PLUS3E       6
#define ZXSTMID_PENTAGON128  7
#define ZXSTMID_TC2048       8
#define ZXSTMID_TC2068       9
#define ZXSTMID_SCORPION    10


typedef struct _tagZXSTHEADER
{
  u_int32_t dwMagic;
  u_int8_t  chMajorVersion;
  u_int8_t  chMinorVersion;
  u_int8_t  chMachineId;
  u_int8_t  chReserved;
} ZXSTHEADER, *LPZXSTHEADER;

// Block Header. Each real block starts
// with this header.
typedef struct _tagZXSTBLOCK
{
  u_int32_t dwId;
  u_int32_t dwSize;
} ZXSTBLOCK, *LPZXSTBLOCK;

// Ram pages are compressed using Zlib
#define ZXSTRF_COMPRESSED       1

// Standard 16kb Spectrum RAM page
typedef struct _tagZXSTRAMPAGE
{
  ZXSTBLOCK blk;
  u_int16_t wFlags;
  u_int8_t chPageNo;
  u_int8_t chData[1];
} ZXSTRAMPAGE, *LPZXSTRAMPAGE;

// Timex Sinclair memory paging and screen modes
typedef struct _tagZXSTSCLDREGS
{
  ZXSTBLOCK blk;
  u_int8_t chF4;
  u_int8_t chFf;
} ZXSTSCLDREGS, *LPZXSTSCLDREGS;

