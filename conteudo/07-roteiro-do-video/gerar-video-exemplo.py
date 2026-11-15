"""Compatibility entry point for the repository-images reference edit."""
import runpy
from pathlib import Path
runpy.run_path(str(Path(__file__).with_name('gerar-video-com-imagens.py')), run_name='__main__')