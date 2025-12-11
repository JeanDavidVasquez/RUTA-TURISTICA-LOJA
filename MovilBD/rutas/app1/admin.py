from django.contrib import admin
from django import forms
from .models import (
    Usuario, Resena, Categoria, Lugar, Favorito,
    Evento, Ruta, Ruta_Guardada, Ruta_Lugar,
    Provincia, Canton, Parroquia
)

# --- INLINES ---
class RutaLugarInline(admin.TabularInline):
    model = Ruta_Lugar
    extra = 1
    fields = ('lugar', 'orden', 'tiempo_sugerido_minutos')
    ordering = ('orden',)

class FavoritoInline(admin.TabularInline):
    model = Favorito
    extra = 0
    readonly_fields = ('fechaGuardado',)

class RutaGuardadaInline(admin.TabularInline):
    model = Ruta_Guardada
    extra = 0
    readonly_fields = ('fechaGuardado',)

# --- FORMS ---
class LugarAdminForm(forms.ModelForm):
    # Campos virtuales para el filtrado en cascada
    provincia_selector = forms.ModelChoiceField(
        queryset=Provincia.objects.all(), 
        required=False, 
        label="Filtrar Provincia"
    )
    canton_selector = forms.ModelChoiceField(
        queryset=Canton.objects.none(), 
        required=False, 
        label="Filtrar Cantón"
    )

    class Meta:
        model = Lugar
        fields = '__all__'

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        
        # Si ya hay una ubicación seleccionada, inicializar los selectores
        if self.instance.pk and self.instance.ubicacion:
            self.fields['canton_selector'].queryset = Canton.objects.filter(provincia=self.instance.ubicacion.canton.provincia)
            self.initial['provincia_selector'] = self.instance.ubicacion.canton.provincia
            self.initial['canton_selector'] = self.instance.ubicacion.canton

        # Lógica para cargar cantones si se seleccionó provincia en el request (si falla JS)
        if 'provincia_selector' in self.data:
            try:
                provincia_id = int(self.data.get('provincia_selector'))
                self.fields['canton_selector'].queryset = Canton.objects.filter(provincia_id=provincia_id).order_by('nombre')
            except (ValueError, TypeError):
                pass

# --- ADMINS ---

@admin.register(Usuario)
class UsuarioAdmin(admin.ModelAdmin):
    list_display = ('username', 'email', 'nombreDisplay', 'fechaCreacion')
    search_fields = ('username', 'email', 'nombreDisplay')
    inlines = [FavoritoInline, RutaGuardadaInline]

@admin.register(Lugar)
class LugarAdmin(admin.ModelAdmin):
    form = LugarAdminForm
    list_display = ('nombre', 'get_provincia', 'get_canton', 'get_parroquia')
    search_fields = ('nombre', 'descripcion', 'direccionCompleta')
    list_filter = ('ubicacion__canton__provincia', 'ubicacion__canton')
    
    # Ocultamos los campos legacy de texto y mostramos los selectores y la ubicación real
    fieldsets = (
        ('Información General', {
            'fields': ('nombre', 'descripcion', 'categorias', 'urlImagenPrincipal')
        }),
        ('Ubicación', {
            'fields': ('provincia_selector', 'canton_selector', 'ubicacion', 'direccionCompleta', 'latitud', 'longitud')
        }),
        ('Detalles', {
            'fields': ('horarios', 'contacto')
        }),
    )

    class Media:
        js = ('admin/js/location_dropdowns.js',)

    def get_provincia(self, obj):
        return obj.ubicacion.canton.provincia.nombre if obj.ubicacion else "-"
    get_provincia.short_description = 'Provincia'

    def get_canton(self, obj):
        return obj.ubicacion.canton.nombre if obj.ubicacion else "-"
    get_canton.short_description = 'Cantón'

    def get_parroquia(self, obj):
        return obj.ubicacion.nombre if obj.ubicacion else "-"
    get_parroquia.short_description = 'Parroquia'

@admin.register(Ruta)
class RutaAdmin(admin.ModelAdmin):
    list_display = ('nombre', 'usuario', 'visibilidadRuta', 'tiempo_total_estimado', 'distanciaEstimadaKm')
    list_filter = ('visibilidadRuta', 'categorias')
    search_fields = ('nombre', 'descripcion')
    inlines = [RutaLugarInline]

@admin.register(Resena)
class ResenaAdmin(admin.ModelAdmin):
    list_display = ('usuario', 'get_target', 'calificacion', 'fechaCreacion')
    list_filter = ('calificacion',)
    search_fields = ('usuario__username', 'texto')
    
    def get_target(self, obj):
        return obj.lugar.nombre if obj.lugar else (obj.ruta.nombre if obj.ruta else "-")
    get_target.short_description = 'Reseñado'

@admin.register(Evento)
class EventoAdmin(admin.ModelAdmin):
    list_display = ('nombre', 'fechaEvento', 'lugar', 'categoriaEvento')
    list_filter = ('categoriaEvento',)
    search_fields = ('nombre', 'descripcion')
    raw_id_fields = ('lugar',)

# Registro de nuevos modelos de ubicación
admin.site.register(Provincia)
admin.site.register(Canton)
admin.site.register(Parroquia)
admin.site.register(Categoria)