# FFmpeg-cross-RPi [WIP]
## Compiling FFmpeg for Raspberry Pi Z/1 on Debian (WSL)
### Source
https://trac.ffmpeg.org/wiki/CompilationGuide/RaspberryPi#Cross-compilingFFmpegforRaspbian
### Unresolved issues 
 - `PKG_CONFIG_PATH`: where should it be pointing?
 - `mmal, omx, omx-rpi`: where to find sources? how to compile them? where to put the compiled file?
 
### What works
 - compiles correclty without the libraries mentioned above
