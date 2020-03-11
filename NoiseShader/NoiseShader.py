import os
from skimage import io, data_dir
from matplotlib import pyplot as plt
from skimage.transform import rescale, resize

os.chdir('C:\\Art\\NoiseShader')
img = io.imread('images\\gjb.jpg')

plt.imshow(img)
plt.show()