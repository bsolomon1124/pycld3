#!/usr/bin/env python

import shutil
import subprocess
from distutils.command.build import build
from os import makedirs, path

from setuptools import Extension, setup

try:
    from Cython.Build import cythonize
except ImportError:
    # ModuleNotFoundError is Python 3.6+
    HAS_CYTHON = False
else:
    HAS_CYTHON = True

HERE = path.abspath(path.dirname(__file__))

# List of source filenames, relative to the distribution root
# (where the setup script lives)
SOURCES = [
    "src/base.cc",
    "src/cld_3/protos/feature_extractor.pb.cc",
    "src/cld_3/protos/sentence.pb.cc",
    "src/cld_3/protos/task_spec.pb.cc",
    "src/embedding_feature_extractor.cc",
    "src/embedding_network.cc",
    "src/feature_extractor.cc",
    "src/feature_types.cc",
    "src/fml_parser.cc",
    "src/lang_id_nn_params.cc",
    "src/language_identifier_features.cc",
    "src/nnet_language_identifier.cc",
    "src/registry.cc",
    "src/relevant_script_feature.cc",
    "src/script_span/fixunicodevalue.cc",
    "src/script_span/generated_entities.cc",
    "src/script_span/generated_ulscript.cc",
    "src/script_span/getonescriptspan.cc",
    "src/script_span/offsetmap.cc",
    "src/script_span/text_processing.cc",
    "src/script_span/utf8statetable.cc",
    "src/sentence_features.cc",
    "src/task_context.cc",
    "src/task_context_params.cc",
    "src/unicodetext.cc",
    "src/utils.cc",
    "src/workspace.cc",
]

if HAS_CYTHON:
    SOURCES.insert(0, "pycld3.pyx")
else:
    # Avoid forcing user to have Cython; let them compile the intermediate
    # CPP source file instead
    # https://cython.readthedocs.io/en/latest/src/userguide/source_files_and_compilation.html#distributing-cython-modules
    SOURCES.insert(0, "pycld3.cpp")

# List of directories to search for C/C++ header files
INCLUDES = [
    "/usr/local/include/",
    path.join(HERE, "src/"),
    path.join(HERE, "src/cld_3/protos/"),
]

# List of library names (not filenames or paths) to link against
LIBRARIES = ["protobuf"]

# https://docs.python.org/3/distutils/setupscript.html#describing-extension-modules
ext = [
    Extension(
        "cld3",  # Name of the extension by which it can be imported
        sources=SOURCES,
        include_dirs=INCLUDES,
        libraries=LIBRARIES,
        language="c++",
        extra_compile_args=["-std=c++11"],
    )
]

# .proto files define protocol buffer message formats
# https://developers.google.com/protocol-buffers/docs/cpptutorial
PROTOS = ["sentence.proto", "feature_extractor.proto", "task_spec.proto"]


class BuildProtobuf(build):
    """Compile protocol buffers via `protoc` compiler"""

    def run(self):

        # Raise & exit early if `protoc` compiler not available
        if shutil.which("protoc") is None:
            raise RuntimeError(
                "The Protobuf compiler, `protoc`, which is required for"
                " installing this package, could not be found."
                " See https://github.com/protocolbuffers/protobuf for"
                " information on installing Protobuf."
            )

        # Create protobufs dir if it does not exist
        protobuf_dir = path.join(HERE, "src/cld_3/protos/")
        if not path.exists(protobuf_dir):
            print("Creating dirs at \033[1m{}\033[0;0m".format(protobuf_dir))
            makedirs(protobuf_dir)

        # Run command via subprocess, using protoc compiler on .proto
        # files
        #
        # $ cd src && protoc --cpp-out cld_3/protos \
        # >     sentence.proto feature_extractor.proto task_spec.proto
        command = ["protoc"]
        command.extend(PROTOS)
        command.append(
            "--cpp_out={}".format(path.join(HERE, "src/cld_3/protos/"))
        )
        print("Running \033[1m{}\033[0;0m".format(" ".join(command)))
        subprocess.run(command, check=True, cwd=path.join(HERE, "src/"))
        build.run(self)


CLASSIFIERS = [
    "License :: OSI Approved :: Apache Software License",
    "Programming Language :: Python :: Implementation :: CPython",
    "Programming Language :: Python",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.5",
    "Programming Language :: Python :: 3.6",
    "Programming Language :: Python :: 3.7",
    "Programming Language :: Python :: 3.8",
    "Programming Language :: C++",
    "Development Status :: 3 - Alpha",
    "Topic :: Text Processing :: Linguistic",
    "Intended Audience :: Developers",
]

if __name__ == "__main__":

    # https://docs.python.org/3/distutils/setupscript.html#additional-meta-data
    if HAS_CYTHON:
        extensions = cythonize(ext)
    else:
        extensions = ext

    setup(
        name="pycld3",
        version="0.14",
        cmdclass={"build": BuildProtobuf},
        author="Brad Solomon",
        maintainer="Brad Solomon",
        author_email="brad.solomon.1124@gmail.com",
        maintainer_email="brad.solomon.1124@gmail.com",
        description="CLD3 Python bindings",
        long_description=open(path.join(HERE, "README.md")).read(),
        long_description_content_type="text/markdown",
        license="Apache 2.0",
        keywords=["cld3", "cffi"],
        url="https://github.com/bsolomon1124/pycld3",
        ext_modules=extensions,
        python_requires=">=3",
        classifiers=CLASSIFIERS,
    )
