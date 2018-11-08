#!/bin/sh

set -e

# Generate Singularity file (does not include last --cmd option)
generate_singularity() {
  docker run --rm kaczmarj/neurodocker:0.4.2 generate singularity \
  --base neurodebian:stretch-non-free \
  --pkg-manager apt \
  --install convert3d ants fsl gcc g++ graphviz tree \
            git-annex-standalone vim emacs-nox nano less ncdu \
            tig git-annex-remote-rclone octave netbase \
  --add-to-entrypoint "source /etc/fsl/fsl.sh" \
  --spm12 version=dev \
  --dcm2niix version=latest method=source \
  --petpvc version=1.2.2 method=binaries \
  --user=neuro \
  --miniconda \
    conda_install="python=3.6 pytest jupyter jupyterlab jupyter_contrib_nbextensions
                   traits pandas matplotlib scikit-learn scikit-image seaborn nbformat nb_conda XlsxWriter" \
    pip_install="https://github.com/nipy/nipype/tarball/master
                 nilearn nipy duecredit nbval" \
    create_env="neuro" \
    activate=true \
  --run-bash 'source activate neuro && jupyter nbextension enable exercise2/main && jupyter nbextension enable spellchecker/main' \
  --user=root \
  --run 'mkdir /data && chmod 777 /data && chmod a+s /data' \
  --run 'mkdir /output && chmod 777 /output && chmod a+s /output' \
  --user=neuro \
  --user=root \
  --run 'rm -rf /opt/conda/pkgs/*' \
  --user=neuro \
  --run 'mkdir -p ~/.jupyter && echo c.NotebookApp.ip = \"0.0.0.0\" > ~/.jupyter/jupyter_notebook_config.py' \
  --workdir /home/neuro
}

generate_singularity > Singularity
