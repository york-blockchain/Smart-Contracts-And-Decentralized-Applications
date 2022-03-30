## Demo : Oracle

## Installation

1. Clone

   ```bash
    mkdir Oracle && \
    cd ./Oracle && \ 
    git init && \ 
    git remote add origin -f https://github.com/york-blockchain/Smart-Contracts-And-Decentralized-Applications.git && \
    git sparse-checkout init && \
    git sparse-checkout set class-11/examples/Oracle && \
    git pull origin master && \ 
    mv class-11/examples/Oracle/* . && \
    rm -rf ./.git ./notes
   ```

