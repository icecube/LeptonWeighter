# LeptonWeighter
Weights injected neutrino final states to neutrino fluxes.

Author: C.A. Arg\"uelles

Reviewer: A. Schneider

If there are any problems do not hesitate to email: caad@mit.edu

# Compilation instructions

Use the provided configure script. Try:

./configure --help

# Prerequesites

This software need the following nontrivial libraries:

* C++11 capable compiler. If working on the cobalt system do:
source scl_source enable devtoolset-2
* Boost 1.55
* Photospline-v2: https://github.com/cnweaver/photospline
* nuSQuIDS: https://github.com/arguelles/nuSQuIDS
* NewNuFlux-v2: http://code.icecube.wisc.edu/svn/sandbox/cweaver/NewNuFlux-new-photospline/

# Examples

The examples can be found in resources/example.

# Detailed Installation Instructions

These instructions are written under the assumption that you are installing LeptonWeighter on the Cobalts. 

I assume you already have py3-v4.1.1 loaded. Should work for other cvmfs env builds too.
You'll want to load your icetray env-shell before this too.

```
export LW_SRC="/data/user/$USER/leptonweighter/py3-v4.1.1/src"
export LW_BUILD="/data/user/$USER/leptonweighter/py3-v4.1.1/"
mkdir -p $LW_SRC
python -m venv $LW_BUILD
source $LW_BUILD/bin/activate
python -m pip install numpy pkgconfig ipython
PREFIX=${SROOT} python -m pip install git+https://github.com/icecube/nuflux

cd $LW_SRC
git clone git@github.com:jsalvado/SQuIDS.git
cd SQuIDS
./configure --prefix=$LW_BUILD
make && make install
export PKG_CONFIG_PATH="$LW_BUILD/lib/pkgconfig:$PKG_CONFIG_PATH"

cd $LW_SRC
git clone https://github.com/arguelles/nuSQuIDS
cd nuSQuIDS/
./configure --prefix=$LW_BUILD --with-python-bindings --python-bin=`which python` --python-module-dir=$LW_BUILD/lib/python3.7/site-packages --with-boost-incdir=$SROOT/include --with-boost-libdir=$SROOT/lib
make && make install && make python && make python-install
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LW_BUILD/lib
export PYTHONPATH=$LW_SRC/nuSQuIDS/resources/python/bindings/:$PYTHONPATH

cd $LW_SRC
git clone https://github.com/icecube/LeptonWeighter
cd LeptonWeighter/
./configure --prefix=$LW_BUILD --with-boost=$SROOT
make && make install && make python && make python-install
```

Note that you'll likely need to push the export commands above to your environment as well.


# Detailed author contributions and citation

The LeptonInjector and LeptonWeighter modules were motivated by the high-energy light sterile neutrino search performed by B. Jones and C. Argüelles. C. Weaver wrote the first implementation of LeptonInjector using the IceCube internal software framework, icetray, and wrote the specifications for LeptonWeighter. In doing so, he also significantly enhanced the functionality of IceCube's Earth-model service. These weighting specifications were turned into code by C. Argüelles in LeptonWeighter. B. Jones performed the first detailed Monte Carlo comparisons that showed that this code had similar performance to the standard IceCube neutrino generator at the time for throughgoing muon neutrinos.

It was realized that these codes could have use beyond IceCube and could benefit the broader neutrino community. The codes were copied from IceCube internal subversion repositories to this GitHub repository; unfortunately, the code commit history was not preserved in this process. Thus the current commits do not represent the contributions from the original authors, particularly from the initial work by C. Weaver and C. Argüelles. 

The transition to this public version of the code has been spearheaded by A. Schneider and B. Smithers, with significant input and contributions from C. Weaver and C. Argüelles. B. Smithers isolated the components of the code needed to make the code public, edited the examples, and improved the interface of the code. A. Schneider contributed to improving the weighting algorithm, particularly to making it work for volume mode cascades, as well as in writing the general weighting formalism that enables joint weighting of volume and range mode.

This project also received contributions and suggestions from internal IceCube reviewers and the collaboration as a whole. Please cite this work as:

LeptonInjector and LeptonWeighter: A neutrino event generator and weighter for neutrino observatories
IceCube Collaboration
https://arxiv.org/abs/2012.10449
