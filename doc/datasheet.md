## Datasheet

### Overview
The `rng(random number generator)` IP is a fully parameterised soft IP to generate the pseudo random number. The IP features an APB4 slave interface, fully compliant with the AMBA APB Protocol Specification v2.0.

### Feature
* Internal 32-bit LSFR implemented with max sequence
* 32-bit programmable seed register
* Generate one random number per cycle
* Static synchronous design
* Full synthesizable

### Interface
| port name | type        | description          |
|:--------- |:------------|:---------------------|
| apb4      | interface   | apb4 slave interface |

### Register

| name | offset  | length | description |
|:----:|:-------:|:-----: | :---------: |
| [CTRL](#control-register) | 0x0 | 4 | control register |
| [SEED](#seed-reigster) | 0x4 | 4 | seed register |
| [VAL](#val-reigster) | 0x8 | 4 | value register |

#### Control Register
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:1]` | none | reserved |
| `[0:0]` | RW | EN |

reset value: `0x0000_0000`

* EN: 

#### Seed Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:0]` | W | SEED |

reset value: `0x0000_0000`

* SEED:

#### Value Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:0]` | R | VAL |

reset value: `0x0000_0000`

* VAL: 

### Program Guide
The software operation of `rng` is simple. These registers can be accessed by 4-bytes align read and write. C-like pseudocode read operation:
```c
uint32_t val;
val = rng.SYS // read the sys register
val = rng.IDL // read the idl register
val = rng.IDH // read the idh register

```
write operation:
```c
uint32_t val = value_to_be_written;
rng.SYS = val // write the sys register
rng.IDL = val // write the idl register
rng.IDH = val // write the idh register

```

### Resoureces
### References
### Revision History