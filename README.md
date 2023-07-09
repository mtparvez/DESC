**DESC** (Descriptors Extractor for Shape Contours) is a set of tools developed using MATLAB that leverage our research in image representation. DESC can generate shape descriptors for shape outlines (a sequence of points from shape contour) using two bags of words. The first bag uses words that are translation invariants, but not rotation invariants. The second bag uses both translation and rotation invariant descriptors.

A prime feature of DESC is that it can generate multiple descriptions of the same shape outline. The algorithm in DESC that generates multiple descriptions is based on the concept of modality and perspective. By incorporating both perspective and modality, the generated shape representations can effectively capture the essential local features while accommodating the inherent variations in writing styles. 


Use of DESC is relatively simple. The main function of DESC is getMultipleDescriptions, which takes as input three parameters: the x co-ordinates of the point sequence, the y co-ordinates of the point sequence and a structure of options. The (x, y) co-ordinates can be extracted from the contour of an offline shape or from the point sequence of an online stroke. The outputs from getMultipleDescriptions can be controlled by passing four parameters:

•	repCount: maximum how many representations that DESC should generate for a shape.

•	repLevel: controls the perspective [3] of a generated representation. The valid value ranges from 1 – 7 (online shapes), 8 (offline shape).

•	rotationInvariant:  1 if the representations should use rotation invariant codebook, 0 otherwise.

•	isOffline:  1 if the (x, y) co-ordinates are extracted from an offline shape, 0 otherwise.

Function getMultipleDescriptions returns four outputs for a particular shape contour: 

•	descCount: number of many representations extracted for a shape. Can be less than repCount.

•	descShape: list of descriptions for the shape using the codebook.

•	descCode: same as 'descShape', but each word from codebook is replaced by a symbol.

•	segXYAll: a list that contains the (x, y) coordinates of all segments inside each representation.

•	segLenAll: a list that contains the the length (in # of points) of all segments inside each representation.

The code repository contains a function desc_usage that illustrates the usage of getMultipleDescriptions for online strokes, where the online stokes are stored as inkml file. The code repository contains helper functions to read inkml files. 
