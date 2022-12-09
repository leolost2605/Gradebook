# project name and programming language
project('io.github.leolost2605.gradebook', 'vala', 'c')

# Include the translations module
i18n = import('i18n')

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    'src' / 'application.vala',
    'src' / 'grade.vala',
    'src' / 'subject.vala',
    'src' / 'newgradebutton.vala',
    'src' / 'deletebutton.vala',
    'src' / 'new-grade-dialog.vala',
    'src' / 'new-subject-dialog.vala',
    'src' / 'delete-subject-button.vala',
    'src' / 'category.vala',
    'src' / 'edit-subject-button.vala',
    'src' / 'edit-subject-dialog.vala',
    'src' / 'add-category-dialog.vala',
    'src' / 'subject-parser.vala',
    dependencies: [
        dependency('gtk4'),
        dependency('libadwaita-1'),
        dependency('json-glib-1.0')
    ],
    install: true
)

install_data (
	'data' / 'io.github.leolost2605.gradebook.desktop',
	install_dir: get_option('datadir') / 'applications'
)

install_data (
	'data' / 'io.github.leolost2605.gradebook.metainfo.xml',
	install_dir: get_option('datadir') / 'metainfo'
)

# Install our icons in all the required sizes
icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
    install_data(
        'data' / i + '.svg',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i / 'apps',
        rename: meson.project_name() + '.svg'
    )
    install_data(
        'data' / i + '.svg',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i + '@2' / 'apps',
        rename: meson.project_name() + '.svg'
    )
endforeach

subdir ('po')