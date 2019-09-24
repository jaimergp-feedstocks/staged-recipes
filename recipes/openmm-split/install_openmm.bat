mkdir build
cd build

if [%cuda_compiler_version%]==[] set WITH_CUDA="no"
if %cuda_compiler_version%=="None" set WITH_CUDA="no"
if %cuda_compiler_version%!="None" set WITH_CUDA="yes"

if %WITH_CUDA%=="yes" (
    cmake.exe .. -G "NMake Makefiles JOM" ^
        -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
        -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
        -DCMAKE_BUILD_TYPE=Release ^
        -DFFTW_INCLUDES="%LIBRARY_INC%" ^
        -DFFTW_LIBRARY="%LIBRARY_LIB%/fftw3f.lib" ^
        -DCUDA_TOOLKIT_ROOT_DIR="%LIBRARY_BIN%" ^
:: TODO: Does cudatoolkit include OpenCL on Windows?
        -DOPENCL_INCLUDE_DIR="%LIBRARY_INC%" ^
        -DOPENCL_LIBRARY="%LIBRARY_LIB%\x86_64\OpenCL.lib" ^
        -DBUILD_TESTING=OFF
        || goto :error
) else (
    cmake.exe .. -G "NMake Makefiles JOM" ^
        -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
        -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
        -DCMAKE_BUILD_TYPE=Release ^
        -DFFTW_INCLUDES="%LIBRARY_INC%" ^
        -DFFTW_LIBRARY="%LIBRARY_LIB%/fftw3f.lib" ^
        -DBUILD_TESTING=OFF ^
        -DOPENMM_BUILD_OPENCL_LIB=OFF ^
        -DOPENMM_BUILD_DRUDE_OPENCL_LIB=OFF ^
        -DOPENMM_BUILD_RPMD_OPENCL_LIB=OFF ^
        || goto :error
)

jom install || goto :error
jom PythonInstall || goto :error
jom install || goto :error

:: Workaround overlinking warnings
copy %SP_DIR%\simtk\openmm\_openmm* %LIBRARY_BIN% || goto :error
copy %LIBRARY_LIB%\OpenMM* %LIBRARY_BIN% || goto :error
copy %LIBRARY_LIB%\plugins\OpenMM* %LIBRARY_BIN% || goto :error

:: Better location for examples
mkdir %LIBRARY_PREFIX%\share\openmm || goto :error
move %LIBRARY_PREFIX%\examples %LIBRARY_PREFIX%\share\openmm || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit /b %errorlevel%