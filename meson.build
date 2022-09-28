# project name and programming language
project('valapp', 'vala', 'c')

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    'src' / 'application.vala',
    'src' / 'grade.vala',
    'src' / 'subject.vala',
    dependencies: [
        dependency('gtk4'),
        dependency('libadwaita-1'),
        dependency('json-glib-1.0')
    ],
    install: true
)