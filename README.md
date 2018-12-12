# BUILD GLIBC
patchelf --set-interpreter /path/to/newglibc/ld.so --set-rpath /path/to/newglibc/ myapp
https://stackoverflow.com/questions/847179/multiple-glibc-libraries-on-a-single-host
