(function ($) {
    $(document).ready(function () {
        // IDs de los campos en el admin de Django (definidos en LugarAdminForm)
        var provinciaField = $('#id_provincia_selector');
        var cantonField = $('#id_canton_selector');
        var ubicacionField = $('#id_ubicacion');

        // Función para cargar cantones
        function loadCantones(provinciaId) {
            var url = '/ajax/load-cantones/';
            $.ajax({
                url: url,
                data: {
                    'provincia': provinciaId
                },
                success: function (data) {
                    cantonField.html('<option value="">---------</option>');
                    $.each(data, function (key, value) {
                        cantonField.append('<option value="' + value.id + '">' + value.nombre + '</option>');
                    });
                }
            });
        }

        // Función para cargar parroquias (que es el campo 'ubicacion')
        function loadParroquias(cantonId) {
            var url = '/ajax/load-parroquias/';
            $.ajax({
                url: url,
                data: {
                    'canton': cantonId
                },
                success: function (data) {
                    ubicacionField.html('<option value="">---------</option>');
                    $.each(data, function (key, value) {
                        ubicacionField.append('<option value="' + value.id + '">' + value.nombre + '</option>');
                    });
                }
            });
        }

        provinciaField.change(function () {
            var provinciaId = $(this).val();
            loadCantones(provinciaId);
        });

        cantonField.change(function () {
            var cantonId = $(this).val();
            loadParroquias(cantonId);
        });
    });
})(django.jQuery);
