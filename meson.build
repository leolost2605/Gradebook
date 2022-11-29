# project name and programming language
project('valapp', 'vala', 'c')

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
        dependency('libadwaita-1', version: '1.2.0'),
        dependency('json-glib-1.0')
    ],
    install: true
)

subdir ('po')