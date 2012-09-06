CKEDITOR.config.templates_files = [CKEDITOR.getUrl('plugins/templates/wat.js')]
CKEDITOR.config.templates = "wat";


CKEDITOR.addTemplates( 'wat',
    {
        // The name of the subfolder that contains the preview images of the templates.
        imagesPath : CKEDITOR.getUrl( CKEDITOR.plugins.getPath( 'templates' ) + 'images/' ),

        // Template definitions.
        templates :
            [
                {
                    title: 'Bootstrap One Column',
                    image: 'one_column.png',
                    description: 'Bootstrap fluid row with one column',
                    html:
                        '<h1>YOUR_PAGE_TITLE_HERE</h1>' +
                        '<div class="row-fluid">YOUR_CONTENT_HERE</div>'
                },
                {
                    title: 'Bootstrap Two Columns',
                    image: 'two_columns.png',
                    description: 'Bootstrap fluid row with two columns',
                    html:
                        '<h1>YOUR_PAGE_TITLE_HERE</h1>' +
                        '<div class="row-fluid">' +
                            '<div class="span6"><h2>FIRST_COLUMN</h2><p>Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum</p></div>' +
                            '<div class="span6"><h2>SECOND_COLUMN</h2><p>Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum</p></div>' +
                         '</div>'
                },
                {
                    title: 'Bootstrap Hero Page',
                    image: 'hero_page.png',
                    description: 'Huge text-box',
                    html: '<div class="hero-unit">'+
                             '<h1>A HUGE HERO PAGE</h1>' +
                             '<h2>With big fonts</h2>' +
                             '<p>Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum</p>' +
                          '</div>'
                }
            ]
    });
