# Include the translations module
i18n = import('i18n')

# Set our translation domain
add_project_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

i18n.gettext(meson.project_name(),
    args: '--directory=' + meson.source_root(),
    preset: 'glib'
)