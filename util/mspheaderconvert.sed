# Register definitions
s`sfr_b\((.*)\).*;`pub var \1 = \@intToPtr(*volatile u8, \1_ld);`
s`sfr_w\((.*)\).*;`pub var \1 = \@intToPtr(*volatile u16, \1_ld);`
s`sfr_l\((.*)\).*;`pub var \1 = \@intToPtr(*volatile u32, \1_ld);`

# Linker definitions
s`^PROVIDE\(([[:alnum:]_]+)\s+\= (0x[[:xdigit:]]+).*`pub const \1_ld = \2;`

# For now, can't do aliases. Instead, replace P[A-J]OUT_L with more common P[0-9]OUT.
/P[0-9](IN|OUT|DIR|REN|DS|SEL|IES|IE|IFG)/d
s`PA(IN|OUT|DIR|REN|DS|SEL|IES|IE|IFG)_L[^_]`P1\1`
s`PA(IN|OUT|DIR|REN|DS|SEL|IES|IE|IFG)_H[^_]`P2\1`
s`PB(IN|OUT|DIR|REN|DS|SEL|IES|IE|IFG)_L[^_]`P3\1`
s`PB(IN|OUT|DIR|REN|DS|SEL|IES|IE|IFG)_H[^_]`P4\1`
s`PC(IN|OUT|DIR|REN|DS|SEL|IES|IE|IFG)_L[^_]`P5\1`
s`PC(IN|OUT|DIR|REN|DS|SEL|IES|IE|IFG)_H[^_]`P6\1`
s`PD(IN|OUT|DIR|REN|DS|SEL|IES|IE|IFG)_L[^_]`P7\1`
s`PD(IN|OUT|DIR|REN|DS|SEL|IES|IE|IFG)_H[^_]`P8\1`

# Combined bits - Starts with letter
s`^#define ([A-Za-z0-9_]+) (\(?[A-Za-z_]+[()+|*0-9A-Za-z_ ]+\)?)`pub const \1 = \2;`

# Bits definitions of numbers
s`^#define ([A-Za-z0-9_]+) (\(?0x[+|0-9A-Za-z]+\)?)`pub const \1 = \2;`

# Remove everything else
/^pub.*/!d

# Interupt vectors declared by assigning function address as const to section, not with .*_VECTOR declarations
/gVECTOR/d

# Remove intrinsic function calls. We will provide our own if necessary.
/const \S+\s+\=\s+\w+\(.*/d
