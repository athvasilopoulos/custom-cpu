# Memory Parameters
This file contains the parameters used to generate the instruction and data memories from the Vivado Block Memory Generator on the IP Catalog

## Instruction Memory Parameters
The options not mentioned below remain in their default selection.
| Parameter | Tab | Selection |
|:----:|:-------:|:-------:|
| Component Name | - | blk_mem_gen_0 |
| Memory Type | Basic | Single Port ROM |
| Port A Width | Port A Options | 32 |
| Port A Depth | Port A Options | 65536 |
| Enable Port Type | Port A Options | Use ENA Pin |
| Load Init file | Other Options | Select and load the COE file|

## Data Memory Parameters
The options not mentioned below remain in their default selection.
| Parameter | Tab | Selection |
|:----:|:-------:|:-------:|
| Component Name | - | blk_mem_gen_1 |
| Memory Type | Basic | Single Port RAM |
| Write Width | Port A Options | 16 |
| Read Width | Port A Options | 16 |
| Write Depth | Port A Options | 2048 |
| Read Depth | Port A Options | 2048 |
| Enable Port Type | Port A Options | Use ENA Pin |