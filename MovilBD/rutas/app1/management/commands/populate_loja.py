from django.core.management.base import BaseCommand
from app1.models import Lugar, Ruta, Ruta_Lugar, Usuario, Categoria
from django.contrib.auth.hashers import make_password
from decimal import Decimal

class Command(BaseCommand):
    help = 'Popula la base de datos con datos reales de Loja, Ecuador'

    def handle(self, *args, **kwargs):
        self.stdout.write('Iniciando población de datos...')

        # 1. Crear Usuario Admin (si no existe)
        user, created = Usuario.objects.get_or_create(
            username='admin_loja',
            defaults={
                'email': 'admin@loja.com',
                'password': make_password('admin123'),
                'nombreDisplay': 'Admin Loja'
            }
        )
        if created:
            self.stdout.write('Usuario admin creado.')
        else:
            self.stdout.write('Usuario admin ya existe.')

        # 2. Crear Categorías
        cat_turismo, _ = Categoria.objects.get_or_create(nombre='Turismo', defaults={'urlIcono': 'tourist_icon.png'})
        cat_parque, _ = Categoria.objects.get_or_create(nombre='Parque', defaults={'urlIcono': 'park_icon.png'})
        cat_cultura, _ = Categoria.objects.get_or_create(nombre='Cultura', defaults={'urlIcono': 'culture_icon.png'})

        # 3. Crear Lugares (Datos Reales de Loja)
        lugares_data = [
            {
                'nombre': 'Puerta de la Ciudad',
                'descripcion': 'Monumento icónico de Loja, entrada al centro histórico. Museo y mirador.',
                'latitud': Decimal('-3.987654'),
                'longitud': Decimal('-79.204567'),
                'direccionCompleta': 'Av. Gran Colombia y Machala',
                'categorias': [cat_turismo, cat_cultura],
                'urlImagenPrincipal': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Puerta_de_la_Ciudad_de_Loja.jpg/800px-Puerta_de_la_Ciudad_de_Loja.jpg'
            },
            {
                'nombre': 'Parque Jipiro',
                'descripcion': 'Parque recreacional con réplicas de monumentos mundiales.',
                'latitud': Decimal('-3.975432'),
                'longitud': Decimal('-79.201234'),
                'direccionCompleta': 'Av. Salvador Bustamante Celi',
                'categorias': [cat_turismo, cat_parque],
                'urlImagenPrincipal': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Parque_Jipiro.jpg/800px-Parque_Jipiro.jpg'
            },
            {
                'nombre': 'Catedral de Loja',
                'descripcion': 'Iglesia principal ubicada en el parque central.',
                'latitud': Decimal('-3.995678'),
                'longitud': Decimal('-79.203456'),
                'direccionCompleta': 'Bernardo Valdivieso y José Antonio Eguiguren',
                'categorias': [cat_turismo, cat_cultura],
                'urlImagenPrincipal': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/Catedral_de_Loja.jpg/800px-Catedral_de_Loja.jpg'
            },
            {
                'nombre': 'Parque Eólico Villonaco',
                'descripcion': 'Parque de generación de energía con vistas panorámicas increíbles.',
                'latitud': Decimal('-4.001234'),
                'longitud': Decimal('-79.256789'),
                'direccionCompleta': 'Vía antigua a Catamayo',
                'categorias': [cat_turismo],
                'urlImagenPrincipal': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Parque_E%C3%B3lico_Villonaco.jpg/800px-Parque_E%C3%B3lico_Villonaco.jpg'
            }
        ]

        lugares_objs = {}
        for l_data in lugares_data:
            cats = l_data.pop('categorias')
            lugar, _ = Lugar.objects.update_or_create(
                nombre=l_data['nombre'],
                defaults=l_data
            )
            lugar.categorias.set(cats)
            lugares_objs[lugar.nombre] = lugar
            self.stdout.write(f'Lugar procesado: {lugar.nombre}')

        # 4. Crear Ruta
        ruta, created = Ruta.objects.get_or_create(
            nombre='Ruta Turística Loja Clásica',
            defaults={
                'descripcion': 'Un recorrido por los puntos más emblemáticos de la ciudad.',
                'visibilidadRuta': 'PUBLIC',
                'duracionEstimadaSeg': 14400, # 4 horas
                'distanciaEstimadaKm': 15.5,
                'usuario': user,
                'urlImagenPortada': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Puerta_de_la_Ciudad_de_Loja.jpg/800px-Puerta_de_la_Ciudad_de_Loja.jpg'
            }
        )
        if created:
            ruta.categorias.add(cat_turismo)
            self.stdout.write('Ruta creada.')

        # 5. Asignar Lugares a la Ruta (Ordenados)
        # Orden: Puerta -> Catedral -> Jipiro -> Villonaco
        orden_lugares = [
            'Puerta de la Ciudad',
            'Catedral de Loja',
            'Parque Jipiro',
            'Parque Eólico Villonaco'
        ]

        # Limpiar ruta existente para evitar duplicados en re-runs
        Ruta_Lugar.objects.filter(ruta=ruta).delete()

        for idx, nombre_lugar in enumerate(orden_lugares):
            if nombre_lugar in lugares_objs:
                Ruta_Lugar.objects.create(
                    ruta=ruta,
                    lugar=lugares_objs[nombre_lugar],
                    orden=idx + 1
                )
        
        self.stdout.write(self.style.SUCCESS('Datos poblados exitosamente!'))
