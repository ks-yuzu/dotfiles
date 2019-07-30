# acap.pl の存在チェック
if [ ! ${+commands[acap.pl]} ]; then
    return
fi



# vivado
export PATH=${HOME}/opt/Vivado/2016.4/bin:$PATH

# acap-dir
export ACAP_DIR="$HOME/tools/acap"
export MIPSLITE_DIR="$HOME/tools/mipslite"
export MIPS_ELF_GCC_LIB_DIR="$HOME/tools/acap/lib"

# acap
export PATH=${ACAP_DIR}/bin:$PATH
export LIBDIR=${ACAP_DIR}/ccaplib 
export PATH=${MIPS_ELF_GCC_LIB_DIR}/mips-elf/gcc-4.8.2/bin:$PATH
export LD_LIBRARY_PATH=${MIPS_ELF_GCC_LIB_DIR}/mpc-1.0.2/lib:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${MIPS_ELF_GCC_LIB_DIR}/mpfr-3.1.2/lib:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${MIPS_ELF_GCC_LIB_DIR}/gmp-6.0.0/lib:${LD_LIBRARY_PATH}
export SOFT_FP_DIR=${MIPS_ELF_GCC_LIB_DIR}/gcc-4.8.2/build/mips-elf/soft-float/el/libgcc

# alias
alias acap='acap.pl -Z1 -Dall --remain-linked-object -l synthesized/ --enable-inlining'
alias ise='ise >/dev/null 2>&1 &'
alias vivado='vivado >/dev/null 2>&1 &'


function clean-acap {
    local dir='.'
    if [ -d synthesized ]; then
        dir='synthesized'
    fi
    
    rm -f $dir/*.o
    rm -f $dir/*.s
    rm -f $dir/*.0
    rm -f $dir/user.obj
    rm -f $dir/*.out
    rm -f $dir/*.dmem
    rm -f $dir/*.txt
    rm -f $dir/*_i.mem
    rm -f $dir/*_d.mem
    rm -f $dir/*.low
    rm -f $dir/*.dfa
    rm -f $dir/*.sch
    rm -f $dir/*.bnd
    rm -f $dir/*.stl
    rm -f $dir/*.rtl
    rm -f $dir/*.v
}