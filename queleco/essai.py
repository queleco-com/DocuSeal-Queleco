"""Essai de POST /api/templates/pdf sur un DocuSeal jetable construit depuis ce dépôt.

    DOCUSEAL_URL=http://127.0.0.1:3000 DOCUSEAL_TOKEN=… python3 queleco/essai.py

Bibliothèque standard seulement. Crée un modèle depuis un PDF à un champ AcroForm,
vérifie le champ et le refus d'un fichier qui n'est pas un PDF.
"""

import base64
import json
import os
import urllib.error
import urllib.request

URL = os.environ["DOCUSEAL_URL"].rstrip("/")
TOKEN = os.environ["DOCUSEAL_TOKEN"]


def pdf_with_field() -> bytes:
    objects = [
        "<< /Type /Catalog /Pages 2 0 R /AcroForm << /Fields [4 0 R] >> >>",
        "<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
        "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Annots [4 0 R] /Contents 5 0 R >>",
        "<< /Type /Annot /Subtype /Widget /FT /Tx /T (nom) /Rect [72 600 300 624] /P 3 0 R /F 4 >>",
        "<< /Length 0 >>\nstream\n\nendstream",
    ]
    out, offsets = bytearray(b"%PDF-1.4\n"), []
    for number, body in enumerate(objects, 1):
        offsets.append(len(out))
        out += f"{number} 0 obj\n{body}\nendobj\n".encode()
    xref = len(out)
    out += f"xref\n0 {len(objects) + 1}\n0000000000 65535 f \n".encode()
    out += "".join(f"{o:010d} 00000 n \n" for o in offsets).encode()
    out += f"trailer\n<< /Size {len(objects) + 1} /Root 1 0 R >>\nstartxref\n{xref}\n%%EOF\n".encode()
    return bytes(out)


def call(method, path, body=None):
    request = urllib.request.Request(
        URL + path, method=method, data=json.dumps(body).encode() if body is not None else None,
        headers={"X-Auth-Token": TOKEN, "Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(request) as answer:
            return answer.status, json.load(answer)
    except urllib.error.HTTPError as error:
        return error.code, json.load(error)


def main():
    file = base64.b64encode(pdf_with_field()).decode()
    status, template = call("POST", "/api/templates/pdf", {"name": "Essai", "documents": [{"name": "essai.pdf", "file": file}]})
    assert status == 200, (status, template)
    assert [f["name"] for f in template["fields"]] == ["nom"], template["fields"]
    assert template["source"] == "api", template["source"]

    status, answer = call("POST", "/api/templates/pdf", {"documents": [{"file": base64.b64encode(b"<html>").decode()}]})
    assert status == 422 and "PDF en base64" in answer["error"], (status, answer)
    print(f"ok: modèle {template['id']} créé par l'API, champ « nom » lu, fichier non PDF refusé")


if __name__ == "__main__":
    main()
