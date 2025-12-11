from django.db import models

DECIMAL_PRECISION = 10
DECIMAL_PLACES = 6 

class Usuario(models.Model):
    username = models.CharField(max_length=150, unique=True)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=128)
    nombreDisplay = models.CharField(max_length=200, blank=True, null=True)
    varFoto = models.CharField(max_length=255, blank=True, null=True)
    fechaCreacion = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.username

class Categoria(models.Model):
    nombre = models.CharField(max_length=100, unique=True)
    urlIcono = models.CharField(max_length=255, blank=True, null=True)
    urlImagen = models.CharField(max_length=255, blank=True, null=True)

    def __str__(self):
        return self.nombre

class Lugar(models.Model):
    nombre = models.CharField(max_length=200)
    descripcion = models.TextField()
    latitud = models.DecimalField(max_digits=DECIMAL_PRECISION, decimal_places=DECIMAL_PLACES)
    longitud = models.DecimalField(max_digits=DECIMAL_PRECISION, decimal_places=DECIMAL_PLACES)
    direccionCompleta = models.CharField(max_length=255, blank=True, null=True)
    provincia = models.CharField(max_length=100, blank=True, null=True)
    canton = models.CharField(max_length=100, blank=True, null=True)
    parroquia = models.CharField(max_length=100, blank=True, null=True)
    horarios = models.CharField(max_length=255, blank=True, null=True)
    contacto = models.CharField(max_length=200, blank=True, null=True)
    urlImagenPrincipal = models.CharField(max_length=255, blank=True, null=True)

    # --- MODIFICADO: ---
    # Cambiamos ForeignKey por ManyToManyField para que un lugar pueda tener varias categorías
    # (Ej: Un lugar puede ser "Histórico" y "Religioso" a la vez, como la Catedral).
    categorias = models.ManyToManyField(Categoria, related_name='lugares')
    
    # Mantenemos tu campo anterior comentado por si acaso, pero el de arriba es el que usa la App
    # categoria = models.ForeignKey(Categoria, on_delete=models.SET_NULL, null=True)

    def __str__(self):
        return self.nombre

class Resena(models.Model):
    texto = models.TextField()
    calificacion = models.IntegerField()
    fechaCreacion = models.DateTimeField(auto_now_add=True)
    lugar = models.ForeignKey(Lugar, on_delete=models.CASCADE)
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE)

    def __str__(self):
        return f"Reseña de {self.calificacion} estrellas"

# --- MODIFICADO: ---
# Usamos tu tabla 'Favorito' para manejar también Pendientes y Visitados
class Favorito(models.Model):
    TIPOS = [
        ('FAV', 'Favorito'),       # Corazón
        ('PEND', 'Pendiente'),     # Quiero ir
        ('VISIT', 'Visitado'),     # Ya fui
    ]

    fechaGuardado = models.DateTimeField(auto_now_add=True)
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE)
    lugar = models.ForeignKey(Lugar, on_delete=models.CASCADE)
    
    # Agregamos este campo para saber en qué pestaña de "Mis Listas" va
    tipo = models.CharField(max_length=10, choices=TIPOS, default='FAV')

    class Meta:
        # Ahora la unicidad depende también del tipo (o puedes dejarlo solo usuario/lugar si un lugar solo puede tener 1 estado)
        unique_together = ('usuario', 'lugar', 'tipo')

    def __str__(self):
        return f"{self.usuario.username} - {self.lugar.nombre} ({self.tipo})"

class Evento(models.Model):
    nombre = models.CharField(max_length=200)
    descripcion = models.TextField()
    urlImagen = models.CharField(max_length=255, blank=True, null=True)
    fechaEvento = models.DateTimeField()
    categoriaEvento = models.CharField(max_length=100, blank=True, null=True)
    direccionAlternativa = models.CharField(max_length=255, blank=True, null=True)
    lugar = models.ForeignKey(Lugar, on_delete=models.CASCADE)

    def __str__(self):
        return self.nombre

class Ruta(models.Model):
    nombre = models.CharField(max_length=200)
    descripcion = models.TextField()
    visibilidadRuta = models.CharField(max_length=50)
    urlImagenPortada = models.CharField(max_length=255, blank=True, null=True)
    fechaCreacion = models.DateTimeField(auto_now_add=True)
    duracionEstimadaSeg = models.IntegerField()
    distanciaEstimadaKm = models.DecimalField(max_digits=DECIMAL_PRECISION, decimal_places=2)
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE)

    # --- AGREGADO: ---
    # Para poder filtrar rutas en la pestaña "Descubrir" (Ej: Rutas de Senderismo, Rutas Gastronómicas)
    categorias = models.ManyToManyField(Categoria, related_name='rutas')

    def __str__(self):
        return self.nombre

class Ruta_Guardada(models.Model):
    orden = models.IntegerField()
    fechaGuardado = models.DateTimeField(auto_now_add=True)
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE)
    ruta = models.ForeignKey(Ruta, on_delete=models.CASCADE)

    class Meta:
        unique_together = ('usuario', 'ruta')

    def __str__(self):
        return f"Ruta {self.ruta.nombre} guardada por {self.usuario.username}"

class Ruta_Lugar(models.Model):
    fechaGuardado = models.DateTimeField(auto_now_add=True)
    ruta = models.ForeignKey(Ruta, on_delete=models.CASCADE)
    lugar = models.ForeignKey(Lugar, on_delete=models.CASCADE)

    # --- AGREGADO: ---
    # Necesitamos saber el ORDEN (1, 2, 3) para dibujar la línea en el Mapa correctamente
    orden = models.PositiveIntegerField(default=0)

    class Meta:
        unique_together = ('ruta', 'lugar')
        # Ordenamos automáticamente por este campo nuevo
        ordering = ['orden']

    def __str__(self):
        return f"{self.ruta.nombre} - {self.orden}. {self.lugar.nombre}"