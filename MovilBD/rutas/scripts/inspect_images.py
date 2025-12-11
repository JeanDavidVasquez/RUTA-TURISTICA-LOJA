import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'rutas.settings')
django.setup()

from app1.models import Lugar, Ruta

print("--- Lugares ---")
for lugar in Lugar.objects.all():
    print(f"ID: {lugar.id}, Nombre: {lugar.nombre}, URL: {lugar.urlImagenPrincipal}")

print("\n--- Rutas ---")
for ruta in Ruta.objects.all():
    print(f"ID: {ruta.id}, Nombre: {ruta.nombre}, URL: {ruta.urlImagenPortada}")
