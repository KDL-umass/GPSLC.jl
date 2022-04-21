# GPSLC: Gaussian Processes with Structured Latent Confounders

[![](https://img.shields.io/badge/language-julia-Green.svg)](https://julialang.org)
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://kdl-umass.github.io/GPSLC.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://kdl-umass.github.io/GPSLC.jl/dev)
[![CI](https://github.com/KDL-umass/GPSLC.jl/workflows/ci/badge.svg)](https://github.com/kdl-umass/GPSLC.jl/actions?query=workflow%3Aci)
[![codecov](https://codecov.io/gh/kdl-umass/GPSLC.jl/branch/main/graph/badge.svg?token=KBIFQ1D5NH)](https://codecov.io/gh/kdl-umass/GPSLC.jl)

## Description

This project provides a software interface in Julia for performing causal inference using Gaussian processes with structured latent confounders, as defined in the ICML 2020 [paper](http://proceedings.mlr.press/v119/witty20a/witty20a.pdf). 


## Examples

The examples can be run by executing the following line:

```bash
julia examples/basicExample.jl
```

In summary, this code estimates posterior distributions over individual treatment effects given an observational dataset and an intervention assignment.

## Contributing

Please review the contribution instructions in [CONTRIBUTING.md](CONTRIBUTING.md)

## Acknowledgements

The original paper was published by Sam Witty, Kenta Takatsu, David Jensen, and Vikash Mansinghka in 2020. As the git history indicates, Sam Witty (switty) and Kenta Takatsu (Kenta426) made the original contributions to the code during their research process.

This package was compiled by Jack Kenney in 2022 under the guidance of Sam Witty and David Jensen.
