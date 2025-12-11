from django.contrib import admin
from .models import (
    Usuario, Resena, Categoria, Lugar, Favorito,
    Evento, Ruta, Ruta_Guardada, Ruta_Lugar
)

# Permite añadir o editar Lugares dentro de la vista de Ruta
class RutaLugarInline(admin.TabularInline):
    model = Ruta_Lugar
    extra = 1  # Número de formularios vacíos para añadir nuevos

# Permite ver los Favoritos de un Usuario
class FavoritoInline(admin.TabularInline):
    model = Favorito
    extra = 0
    readonly_fields = ('fechaGuardado',)

# Permite ver las Rutas Guardadas por un Usuario
class RutaGuardadaInline(admin.TabularInline):
    model = Ruta_Guardada
    extra = 0
    readonly_fields = ('fechaGuardado',)


# --- ModelAdmin para personalizar la vista en el Administrador ---

@admin.register(Usuario)
class UsuarioAdmin(admin.ModelAdmin):
    list_display = ('username', 'email', 'nombreDisplay', 'fechaCreacion')
    search_fields = ('username', 'email', 'nombreDisplay')
    # Muestra los modelos relacionados dentro del formulario de Usuario
    inlines = [FavoritoInline, RutaGuardadaInline]

@admin.register(Lugar)
class LugarAdmin(admin.ModelAdmin):
    list_display = ('nombre', 'provincia', 'canton')
    list_filter = ('provincia',)
    search_fields = ('nombre', 'descripcion', 'direccionCompleta')
    # Permite buscar la categoría al asignar
    # raw_id_fields = ('categoria',) 

@admin.register(Ruta)
class RutaAdmin(admin.ModelAdmin):
    list_display = ('nombre', 'usuario', 'visibilidadRuta', 'duracionEstimadaSeg', 'distanciaEstimadaKm')
    list_filter = ('visibilidadRuta',)
    search_fields = ('nombre', 'descripcion')
    # Muestra los Lugares que componen la Ruta en el formulario de Ruta
    inlines = [RutaLugarInline]

@admin.register(Resena)
class ResenaAdmin(admin.ModelAdmin):
    list_display = ('usuario', 'lugar', 'calificacion', 'fechaCreacion')
    list_filter = ('calificacion',)
    raw_id_fields = ('usuario', 'lugar') # Útil si hay muchos usuarios/lugares

@admin.register(Evento)
class EventoAdmin(admin.ModelAdmin):
    list_display = ('nombre', 'fechaEvento', 'lugar', 'categoriaEvento')
    list_filter = ('categoriaEvento',)
    search_fields = ('nombre', 'descripcion')
    raw_id_fields = ('lugar',)

# --- Registro de Modelos Simples sin Personalización Extensa ---

admin.site.register(Categoria)


# admin.site.register(Ruta_Lugar)
# admin.site.register(Favorito)
# admin.site.register(Ruta_Guardada)