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

class Provincia(models.Model):
    nombre = models.CharField(max_length=100, unique=True)

    def __str__(self):
        return self.nombre

class Canton(models.Model):
    nombre = models.CharField(max_length=100)
    provincia = models.ForeignKey(Provincia, on_delete=models.CASCADE, related_name='cantones')

    class Meta:
        unique_together = ('nombre', 'provincia')

    def __str__(self):
        return f"{self.nombre} ({self.provincia.nombre})"

class Parroquia(models.Model):
    nombre = models.CharField(max_length=100)
    canton = models.ForeignKey(Canton, on_delete=models.CASCADE, related_name='parroquias')

    class Meta:
        unique_together = ('nombre', 'canton')

    def __str__(self):
        return f"{self.nombre} ({self.canton.nombre})"


class Lugar(models.Model):
    nombre = models.CharField(max_length=200)
    descripcion = models.TextField()
    latitud = models.DecimalField(max_digits=DECIMAL_PRECISION, decimal_places=DECIMAL_PLACES)
    longitud = models.DecimalField(max_digits=DECIMAL_PRECISION, decimal_places=DECIMAL_PLACES)
    direccionCompleta = models.CharField(max_length=255, blank=True, null=True)
    
    # --- MODIFICADO: Ubicación Jerárquica ---
    # Mantenemos los antiguos como backup por si acaso, pero idealmente se migran y eliminan
    provincia = models.CharField(max_length=100, blank=True, null=True)
    canton = models.CharField(max_length=100, blank=True, null=True)
    parroquia = models.CharField(max_length=100, blank=True, null=True)
    
    ubicacion = models.ForeignKey(Parroquia, on_delete=models.SET_NULL, null=True, blank=True, related_name='lugares')
    # ----------------------------------------

    horarios = models.CharField(max_length=255, blank=True, null=True)
    contacto = models.CharField(max_length=200, blank=True, null=True)
    urlImagenPrincipal = models.CharField(max_length=255, blank=True, null=True)

    categorias = models.ManyToManyField(Categoria, related_name='lugares')

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

    categorias = models.ManyToManyField(Categoria, related_name='rutas')

    def __str__(self):
        return self.nombre

    # Propiedad para calcular tiempo total incluyendo paradas
    @property
    def tiempo_total_estimado(self):
        tiempo_paradas = sum(rl.tiempo_sugerido_minutos for rl in self.ruta_lugar_set.all())
        return (self.duracionEstimadaSeg // 60) + tiempo_paradas

class Resena(models.Model):
    texto = models.TextField()
    calificacion = models.IntegerField()
    fechaCreacion = models.DateTimeField(auto_now_add=True)
    
    # --- MODIFICADO: Soporte para Lugares y Rutas ---
    lugar = models.ForeignKey(Lugar, on_delete=models.CASCADE, null=True, blank=True, related_name='resenas')
    ruta = models.ForeignKey(Ruta, on_delete=models.CASCADE, null=True, blank=True, related_name='resenas')
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE)

    class Meta:
        # Un usuario solo puede dejar una reseña por lugar O por ruta
        # unique_together = ('usuario', 'lugar') # Eliminado para permitir flexibilidad
        pass 

    def __str__(self):
        target = self.lugar.nombre if self.lugar else (self.ruta.nombre if self.ruta else "Desconocido")
        return f"Reseña de {self.usuario.username} a {target} ({self.calificacion}*)"

class Favorito(models.Model):
    TIPOS = [
        ('FAV', 'Favorito'),       # Corazón
        ('PEND', 'Pendiente'),     # Quiero ir
        ('VISIT', 'Visitado'),     # Ya fui
    ]

    fechaGuardado = models.DateTimeField(auto_now_add=True)
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE)
    lugar = models.ForeignKey(Lugar, on_delete=models.CASCADE)
    tipo = models.CharField(max_length=10, choices=TIPOS, default='FAV')

    class Meta:
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
    orden = models.PositiveIntegerField(default=0)
    
    # Tiempo sugerido en minutos
    tiempo_sugerido_minutos = models.PositiveIntegerField(default=0, help_text="Tiempo sugerido en minutos para esta parada")
    
    # Comentario o nota sobre la parada
    comentario = models.TextField(blank=True, null=True, help_text="Comentario o nota sobre esta parada en la ruta")

    class Meta:
        unique_together = ('ruta', 'lugar')
        ordering = ['orden']

    def __str__(self):
        return f"{self.ruta.nombre} - {self.orden}. {self.lugar.nombre}"