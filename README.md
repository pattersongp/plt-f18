# FIRE
File Input Reinterpretation Engine

## Team Members

* Language Guru [Christopher Thomas](https://github.com/lord-left) cpt2132
* System Architect [Jason Konikow](https://github.com/jkon1513) jk4057
* System Architect [Frank Spano](https://github.com/fspano118) fas2154
* Tester [Ayer Chan](https://github.com/ochan4) oc2237
* Manager [Graham Patterson](https://github.com/pattersongp) gpp2109
* TA Advisor [John Hui](https://github.com/j-hui)

## Usage

### Docker

For help with Docker installation, see [here](https://docs.docker.com/docker-for-mac/)

0. Navigate to the repository root `cd plt-f18`
1. You'll build a docker image: `docker build -t fire .`
2. To run the container: `docker run --rm -it -v `pwd`:/home/fire -w=/home/fire fire`

Then inside the container you'll be able to run `make` and all build targets.
