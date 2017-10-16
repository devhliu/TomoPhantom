"""
tomophantom.pyx
Phantom 3D Generator
"""

import cython

# import numpy and the Cython declarations for numpy
import numpy as np
cimport numpy as np

# declare the interface to the C code
cdef extern float buildPhantom3D_core(float *A, int ModelSelected, int N, char* ModelParametersFilename)
cdef extern float buildSino3D_core(float *A, int ModelSelected, int N, int P, float *Th, int AngTot, int CenTypeIn, char* ModelParametersFilename)

@cython.boundscheck(False)
@cython.wraparound(False)
def build_volume_phantom_3d(str model_parameters_filename, int model_id, int phantom_size):
	"""
	build_volume_phantom_3d (model_parameters_filename,model_id, phantom_size)
	
	Takes in a input model_id and phantom_size and returns a phantom of phantom_size x phantom_size x phantom_size of type float32 numpy array.
	
	param: model_parameters_filename -- filename for the model parameters
	param: model_id -- a model id from the functions file
	param: phantom_size -- a phantom size in each dimension.
	
	returns: numpy float32 phantom array
	
	"""
	
	cdef np.ndarray[np.float32_t, ndim=3, mode="c"] phantom = np.empty([phantom_size, phantom_size, phantom_size], dtype='float32')
	cdef float ret_val
	py_byte_string = model_parameters_filename.encode('UTF-8')
	cdef char* c_string = py_byte_string
	ret_val = buildPhantom3D_core(&phantom[0,0,0], model_id, phantom_size, c_string)
	return phantom
	
@cython.boundscheck(False)
@cython.wraparound(False)
def build_sinogram_phantom_3d(str model_parameters_filename, int model_id, int volume_size, int detector_size, np.ndarray[np.float32_t, ndim=1, mode="c"] angles, int CenTypeIn):
	"""
	build_sinogram_phantom_3d (model_parameters_filename, model_id, volume_size, detector_size, angles)
	
	Takes in as input model_id, volume_size, detector_size and projection angles and return a 3D sinogram corresponding to the model id.
	
	param: model_parameters_filename -- filename for the model parameters
	param: model_id -- a model id from the functions file
	param: volume_size -- a phantom size in each dimension.
	param: detector_size -- int detector size.
	param: angles -- a numpy array of float values with angles in radians
	param: CenTypeIn -- 1 as default [0: radon, 1:astra]
	returns: numpy float32 phantom sinograms array.
	
	"""
	
	cdef np.ndarray[np.float32_t, ndim=3, mode="c"] sinogram = np.zeros([angles.shape[0], detector_size, volume_size], dtype='float32')
	cdef float ret_val
	py_byte_string = model_parameters_filename.encode('UTF-8')
	cdef char* c_string = py_byte_string    
	cdef int AngTot = angles.shape[0]
	ret_val = buildSino3D_core(&sinogram[0,0,0], model_id, volume_size, detector_size, &angles[0], AngTot, CenTypeIn, c_string)
	return sinogram	