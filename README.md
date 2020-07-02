# Multi-scale Graph-based Grading for Alzheimer’s Disease Prediction

<p>Implementation of Hett et al. Medical Image Analysis 2020 (see accepted paper <a href="https://github.com/hettk">here</a>)</p>


### Summary
- Implementation (graph construction)
    - main function : process_pba.m
- Evaluation
    - main scripts: train.py, test.py


## Abstract
<p align="justify">
The prediction of subjects with mild cognitive impairment (MCI) who will progress to Alzheimer's disease (AD) is clinically relevant, and may above all have a significant impact on accelerating the development of new treatments. In this paper, we present a new MRI-based biomarker that enables us to accurately predict conversion of MCI subjects to AD. In order to better capture the AD signature, we introduce two main contributions. First, we present a new graph-based grading framework to combine inter-subject similarity features and intra-subject variability features. This framework involves patch-based grading of anatomical structures and graph-based modeling of structure alteration relationships. Second, we propose an innovative multiscale brain analysis to capture alterations caused by AD at different anatomical levels. Based on a cascade of classifiers, this multiscale approach enables the analysis of alterations of whole brain structures and hippocampus subfields at the same time. During our experiments using the ADNI-1 dataset, the proposed multiscale graph-based grading method obtained an area under the curve (AUC) of 81% to predict conversion of MCI subjects to AD within three years. Moreover, when combined with cognitive scores, the proposed method obtained 85% of AUC. These results are competitive in comparison to state-of-the-art methods evaluated on the same dataset.</p>

<br>



## Method overview

<p align="justify">
As illustrated in Figure~\ref{fig:gsg_workflow}, our graph of structure grading method that combines inter-subjects' similarities and intra-subjects' variability is composed of several steps. 
</p>

<p align="justify">
First, a segmentation of the structures of interest is computed on the input images. Then, a patch-based grading (PBG) approach is conducted over every segmented structures (e.g., hippocampal subfields and brain structures). The two main alterations impacting the brain structures captured with PBG methods are the changes caused by normal aging \citep{koikkalainen2012improved} and the alterations caused by the progression of AD. Therefore, at each voxel, the grading values are age-corrected to avoid bias due to normal aging. After the patch-based grading maps are age-corrected, we construct an undirected graph to model the topology of alterations caused by Alzheimer's disease. This results in a high dimensional feature vector. Consequently, to reduce the dimensionality of the feature vector computed by our graph-based method, we use an elastic net that provides a sparse representation of the most discriminative elements of our graph (i.e., edges and vertices). We use only the most discriminative features of our graph as the input to a random forest method which predicts the subject's conversion.
</p>

<p align="center"><img src="figures/pipeline.png" width="600"><br>
Fig. 1 Pipeline of the proposed graph-based grading method. PBG is computed using CN and AD training groups. CN group is also used to correct the bias related to age. Then, this estimation is applied to AD and MCI subjects. Afterwards, the graph is constructed, and the feature selection is trained on CN and AD and then is applied to CN, AD and MCI. Finally the classifier is trained with CN and AD.</p>
<br>

## Patch-based grading

<p align="justify">
Following image segmentation, a patch-based grading of the entire brain was performed using the method described in \citep{hett2018adaptive}. This method was first proposed to detect hippocampus structural alterations with a new scale of analysis \citep{coupe2012simultaneous,coupe2012scoring}. The patch-based grading approach provides the probability that the disease has impacted the underlying structure at each voxel. This probability is estimated via an inter-subject similarity measurement derived from a non-local approach.
</p>

<p align="justify">
The method begins by building a training library $T$ from two datasets of images: one with images from CN subjects and the other one from AD patients. Then, for each voxel $x_i$ of the region of interest in the considered subject $x$, the PBG method produces a weak classifier denoted, $g_{x_i}$, that provides a surrogate for the pathological grading at the considered position $i$. A PBG value is computed using a measurement of the similarity between the patch $P_{x_i}$ surrounding the voxel $x_i$ belonging to the image under study and a set $K_{x_i} = \{ P_{t_{j}} \}$ of the closest patches $P_{t_j}$, surrounding the voxel $t_j$, extracted from the template $t \in T$. The grading value $g_{x_i}$ at $x_i$ is defined as:
</p>

<p align="center"><img src="figures/pbd_illustration.png" width="600"><br>
Fig. 2 Schema of the proposed multi-scale graph-based grading method. First, the segmentation maps are used to aggregate grading values. Our method computes a histogram for each structure/subfield. Once the graphs are built, an elastic net is computed to select the most discriminating graph features for each anatomical scale. A first layer of random forest classifiers are computed to estimate a posteriori probabilities. Finally, a linear classifier is trained with the a posteriori probabilities from each anatomical scale to compute the final decision. A random forest classifier replaces the linear classifier for the multimodal experiments to deal with the feature heterogeneity resulting from the concatenation of a posteriori probabilities and cognitive scores.</p>

## Graph Construction

<p align="justify">
Once structure alterations were estimated using patch-based grading, we modeled intra-subject variability for each subject using a graph to better capture the AD signature. \red{Indeed, within the last decade, graph modeling has been widely used for its ability to capture the patterns of different diseases \citep{tong2017multi,parisot2018disease}.} This is achieved by encoding the relationships of abnormalities between different structures in the edges of the graph. Furthermore, graph modeling can also depict inter-subject similarity, by independently encoding the abnormality of each structure in the vertices measurement. Consequently, we proposed a graph-based grading approach that uses a graph model to combine inter-subject similarities computed with the PBG and intra-subjects' variability computed with the difference of the grading value distributions for each structure.
</p>

<p align="justify">
In our graph-based grading method, the segmentation maps were used to fuse grading values into each ROI, and to build our graph. We defined an undirected graph $G=(V, E, \gamma, \omega)$, where $V=\{v_1,...,v_N\}$ is the set of vertices for the $N$ considered brain structures, $E=V \times V$ is the set of edges, $\gamma$ and $\omega$ are two functions of the vertices and the edges, respectively. In our work, $\gamma$ is the mean of the grading values for a given structure while $\omega$ computes grading distribution distance between two structures. To this end, the probability distributions of PBG values were estimated with a histogram $H_v$ for each structure $v$. \red{The number of bins was computed with Sturge's rule \citep{sturges1926choice} using the average of number voxels that compose each brain structure or hippocampal subfields (\emph{i.e.}, histogram of whole brain structures and hippocampal subfields were estimated using different bin number)}. For each vertex we assigned a function $\gamma:V\rightarrow \mathbb{R}$ defined as $\gamma(v) = \mu_{H_v}$, where $\mu_{H_v}$ is the mean of $H_v$. For each edge we assigned a weight given by the function $\omega:E\rightarrow \mathbb{R}$ defined as follows:
</p>

<p align="justify">
where $W$ is the Wasserstein distance with $L_1$ norm \citep{rubner2000earth} that showed best performance during our experiments. \red{Indeed, this metric introduced by the optimal transport theory, aims to minimize the amount of work needed to rearrange the histogram $H_{v_i}$ to $H_{v_j}$.}
</p>

<p align="center"><img src="figures/network.png" width="600"><br>
Fig. 3 Schema of the proposed multi-scale graph-based grading method. First, the segmentation maps are used to aggregate grading values. Our method computes a histogram for each structure/subfield. Once the graphs are built, an elastic net is computed to select the most discriminating graph features for each anatomical scale. A first layer of random forest classifiers are computed to estimate a posteriori probabilities. Finally, a linear classifier is trained with the a posteriori probabilities from each anatomical scale to compute the final decision. A random forest classifier replaces the linear classifier for the multimodal experiments to deal with the feature heterogeneity resulting from the concatenation of a posteriori probabilities and cognitive scores.
</p>



## Features selection

<p align="justify">
Completion of the previous step results in a high-dimensional feature vector. Because features computed from the graph-based grading method have varying significance levels, in this work, we used an elastic net regression method to provide a sparse representation of the most discriminating edges and vertices. This results in reducing the feature dimensionality by capturing the key structures and the key relationships between the different brain structures (see Figure~\ref{fig:gsg_workflow}). Indeed, it has been demonstrated that combining the $L1$ and $L2$ norms takes into account possible inter-feature correlation while imposing sparsity \citep{zou2005regularization}. Finally, after normalization, the resulting feature vector is given as the input of the feature selection, defined as the minimization of the following equation:
</p>

<p align="justify">
where $\hat{\beta}$ is a sparse vector that represents the regression coefficients and $X$ is a matrix with rows corresponding to the subjects and columns corresponding to the features, including: the vertices, the edges or a concatenation of both for the full graph of grading feature vector. $\rho$ and $\lambda$ are the regularization hyper-parameters set to balance the sparsity and the correlation inter-feature, and $y$ represents the pathological status of each patient.
</p>

<p align="center"><img src="figures/network.png" width="600"><br>
Fig. 4 Representation of the most selected structures. The brain structures and hippocampal subfields are selected separately with the elastic net method. Frequently selected structures are colored using opaque red to transparent for structures never selected. (A) the most frequently selected brain structures are the temporal lobe, the postcentral gyrus, the anterior cingulate gyrus, the hippocampus and the precuneus. (B) the most frequently selected hippocampal subfields are the CA1-SP, the CA1-SRLM, and the subiculum.</p>


## References
[1] Coupé, Pierrick, et al. "Simultaneous segmentation and grading of anatomical structures for patient's classification: application to Alzheimer's disease." NeuroImage 59.4 (2012): 3736-3747.

[2] Hett, Kilian, et al. "Adaptive fusion of texture-based grading for Alzheimer's disease classification." Computerized Medical Imaging and Graphics 70 (2018): 8-16.

