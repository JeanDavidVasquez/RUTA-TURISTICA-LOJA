import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'rutas.settings')
django.setup()

from app1.models import Lugar, Ruta

# Image URLs (Unsplash)
IMAGES = {
    'park': 'https://images.unsplash.com/photo-1565118531796-7a30127dbd84?auto=format&fit=crop&w=800&q=80',
    'city': 'https://images.unsplash.com/photo-1548013146-72479768bada?auto=format&fit=crop&w=800&q=80',
    'church': 'https://images.unsplash.com/photo-1569336415962-a4bd9f69cd83?auto=format&fit=crop&w=800&q=80',
    'museum': 'https://images.unsplash.com/photo-1518998053901-5348d3969105?auto=format&fit=crop&w=800&q=80',
    'route': 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=800&q=80',
}

def get_image_for_lugar(nombre):
    nombre = nombre.lower()
    if 'parque' in nombre or 'jardín' in nombre:
        return IMAGES['park']
    elif 'iglesia' in nombre or 'catedral' in nombre or 'templo' in nombre:
        return IMAGES['church']
    elif 'museo' in nombre:
        return IMAGES['museum']
    else:
        return IMAGES['city']

print("Updating Lugares...")
for lugar in Lugar.objects.all():
    new_url = get_image_for_lugar(lugar.nombre)
    lugar.urlImagenPrincipal = new_url
    lugar.save()
    print(f"Updated {lugar.nombre} -> {new_url}")

print("\nUpdating Rutas...")
for ruta in Ruta.objects.all():
    ruta.urlImagenPortada = IMAGES['route']
    ruta.save()
    print(f"Updated {ruta.nombre} -> {IMAGES['route']}")

print("\nDone! All images updated.")
