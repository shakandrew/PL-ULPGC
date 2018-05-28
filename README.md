# PL - Final project
## How to run:
Download and install from sources to some folder LLVM-3.8.1.
In CMaleLists.txt change `LLVM_PATH` to path where LLVM has been installed.
Then run:

`mkdir build && cd build && cmake .. && make && cd ..` 

Then you can write our own program in xlang and compile it with `xlang.sh`:

`./xlang.sh build/xlang path/to/xlang/program/`