# GMMensemble

Source code repository for:

"Unsupervised classification of the northwestern European seas based on satellite altimetry data"
by Lea Poropat , Dan(i) Jones , Simon D. A. Thomas , and Céline Heuzé

Using an ensemble of Gaussian Mixture Models (GMMs) with altimetry data to find the regions of similar interannual to decadal sea level variability in the seas of northwestern Europe.

The preprint can be cited as:

```bibtex
@Article{egusphere-2023-1468,
AUTHOR = {Poropat, L. and Jones, D. and Thomas, S. D. A. and Heuz\'e, C.},
TITLE = {Unsupervised classification of the Northwestern European seas based on satellite altimetry data},
JOURNAL = {EGUsphere},
VOLUME = {2023},
YEAR = {2023},
PAGES = {1--20},
URL = {https://egusphere.copernicus.org/preprints/2023/egusphere-2023-1468/},
DOI = {10.5194/egusphere-2023-1468}
}
```

To create the python environment:

```bash
conda env create -f environment.yml -n gmm

conda activate gmm
```

### List of files
s01_Preprocessing.ipnyb - prepares the satellite altimetry data with already selected region of interest <br>
s02_PCA.ipnyb - principal component analysis to separate the sea level signal into spatial (empirical orthogonal function maps) and temporal (principal component time series) component <br>
s03_GMMnumberOfClasses.ipynb - calculates silhouette score and Bayesian Information Criterion for a span of class numbers to find the best one <br>
s04_GMMensemble.ipynb - main script; applies an ensemble of Gaussian Mixture Models on stacked EOF maps <br>
plot_classification.m - Matlab script used to plot the results of one ensemble (classes and likelihood)
