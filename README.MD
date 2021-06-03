# HOW TO BUILD:
##     Edit sqlrelay.conf with your oracle connection string first!
##     Execute command for build:
       docker build --pull -t sqlr-ora:21 . 

# HOW TO RUN:
##     Run as a daemon:
       docker run -p xxxx:xxxx -itd sqlr-ora:21

##     Run interactively:
       docker run -p xxxx:xxxx -it sqlr-ora:21
