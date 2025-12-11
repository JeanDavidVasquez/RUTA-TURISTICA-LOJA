import os
import django
from django.conf import settings

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'rutas.settings')
django.setup()

from django.test import Client
from app1.models import Ruta

def verify():
    c = Client()
    
    print("--- Verificando Rutas ---")
    response = c.get('/api/rutas/')
    if response.status_code == 200:
        data = response.json()
        print(f"Status: {response.status_code}")
        print(f"Rutas encontradas: {len(data)}")
        if len(data) > 0:
            print(f"Ruta 1: {data[0]['nombre']}")
            ruta_id = data[0]['id']
            
            print(f"\n--- Verificando Puntos de Ruta {ruta_id} ---")
            response_pts = c.get(f'/api/ruta-lugares/?ruta={ruta_id}')
            if response_pts.status_code == 200:
                pts = response_pts.json()
                print(f"Puntos encontrados: {len(pts)}")
                for p in pts:
                    print(f" - Orden {p['orden']}: {p['lugar_nombre']}")
            else:
                print(f"Error fetching points: {response_pts.status_code}")
        else:
            print("No se encontraron rutas.")
    else:
        print(f"Error fetching rutas: {response.status_code}")

if __name__ == '__main__':
    verify()
