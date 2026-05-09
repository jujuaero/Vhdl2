import sys
from pathlib import Path
try:
    from PyPDF2 import PdfReader
except Exception as e:
    raise RuntimeError('PyPDF2 is required. Install with: python -m pip install PyPDF2') from e

def extract_text(pdf_path: Path) -> str:
    reader = PdfReader(str(pdf_path))
    pages = []
    for p in reader.pages:
        text = p.extract_text()
        pages.append(text or "")
    return "\n\n".join(pages)

if __name__ == '__main__':
    wd = Path(__file__).parent
    pdf = Path(sys.argv[1]) if len(sys.argv) > 1 else wd / "TE608 - 25_26 - Conception de systèmes numériques 2 - v1.1.pdf"
    out = Path(sys.argv[2]) if len(sys.argv) > 2 else pdf.with_suffix('.txt')
    txt = extract_text(pdf)
    out.write_text(txt, encoding='utf-8')
    print(f'Wrote: {out}')
