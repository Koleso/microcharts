var basePaths = {
  assets: 'assets',
  src: 'assets/src',
  temp: 'assets/temp',
  dist: 'assets/dist'
};

var proxySnippet = require('grunt-connect-proxy/lib/utils').proxyRequest;

module.exports = function (grunt) {
  grunt.option("src", basePaths.src);
  grunt.option("temp", basePaths.temp);
  grunt.option("dist", basePaths.dist);

  grunt.initConfig({
    clean: {
      before: {
        src: [basePaths.dist+'/**/*']
      },
      after: {
        src: [basePaths.temp]
      }
    },
    
    copy: {
      options: {
        expand: true,
        src: basePaths.src+'/js/libs/',
        dest: basePaths.dist+'/js/libs/'
      },
    },

    svg_sprite: {
      src: [basePaths.src+'/images/svg/*.svg'],
      options: {
        dest: basePaths.dist,
        shape : {
          id : {
            generator : function(name) {
              name = name.replace(/\\/g,"/");
              item = name.split("/");
              return item[item.length - 1].slice(0, -4);
            }
          },
          spacing : {
            padding : 1,
          },
        },
        mode : {
          css : {
            mixin: 'sprite',
            sprite: '../img/sprite.svg',
            prefix: '.sprite-%s',
            dimensions: '-dims',
            render: {
              less: {
                dest: '../../temp/sprite.less',
                template: 'assets/tpl/template.less'
              }
            },
          },
          transform: ['svgo'],
        },
        variables : {
          png: function() {
            return function(sprite, render) {
              return render(sprite).split('.svg').join('.png');
            }
          }
        }
      }
    },

    svgmin: {
      options: {
        plugins: [
          { removeViewBox: false },
          { removeUselessStrokeAndFill: false }
        ]
      },
      dist: {
        expand: true,
        cwd: basePaths.dist+'/',
        src: ['img/*.svg'],
        dest: basePaths.dist+'/',
        ext: '.svg'
      }
    },

    svg2png: {
      all: {
        files: [{
          cwd: basePaths.dist+'/',
          src: ['img/*.svg'],
          dest: basePaths.dist+'/',
          expand: false
        }]
      }
    },

    imagemin: {
      dynamic: {
        files: [{
          expand: true,
          cwd: basePaths.src+'/images/',
          src: ['*.{png,jpg,gif}'],
          dest: basePaths.dist+'/images/'
        }]
      }
    },

    concat: {
      styles: {
        // Kvuli spravnemu poradi je vypsano rucne
        src: [
          basePaths.src+'/less/reset.less', 
          basePaths.src+'/less/mixins.less',
          basePaths.src+'/less/fonts.less',
          basePaths.temp+'/sprite.less',
          basePaths.src+'/less/variables.less',
          basePaths.src+'/less/typography.less',
          basePaths.src+'/less/site.less',
          basePaths.src+'/less/responsive.less',
          basePaths.src+'/less/utilities.less'
        ],
        dest: basePaths.temp+'/style.less'
      },
      scripts: {
        src: [basePaths.src+'/js/*.coffee'],
        dest: basePaths.temp+'/app.coffee',
      }
    },

    less: {
      production: {
        files: {
          '<%= grunt.option(\"temp\") %>/style.css': '<%= grunt.option(\"temp\") %>/style.less'
        }
      }
    },

    postcss: {
      options: {
        mapAnnotation: false,
        processors: [
          //require('autoprefixer')(),
          require('pixrem')(),
          require('cssnano')({discardComments: true})
        ]
      },
      dist: {
        src: basePaths.temp+'/style.css',
        dest: basePaths.dist+'/css/style.min.css'
      }
    },

    coffee: {
      compile: {
        files: {
          '<%= grunt.option(\"temp\") %>/app.js': '<%= grunt.option(\"temp\") %>/app.coffee'
        }
      }
    },

    coffeeify: {
      basic: {
        files: [{
          src: [basePaths.src+'/js/*.coffee'],
          dest: basePaths.temp+'/app.js'
        }]
      }
    },

    babel: {
      options: {
        sourceMap: false,
        presets: ['es2015']
      },
      dist: {
        files: {
          '<%= grunt.option(\"temp\") %>/app.babel.js': ['<%= grunt.option(\"temp\") %>/app.js']
        }
      }
    },

    uglify: {
      dev: {
        files: {
          '<%= grunt.option(\"dist\") %>/js/global.min.js': ['<%= grunt.option(\"temp\") %>/app.js']
        }
      },
      build: {
        files: {
          '<%= grunt.option(\"dist\") %>/js/global.min.js': ['<%= grunt.option(\"temp\") %>/app.babel.js']
        }
      }
    },

    watch: {
      html: {
        files: ['*'],
        options: {
          livereload: 35729
        },
      },
      script: {
        files: [basePaths.src+'/js/*'],
        tasks: ['javascript_dev'],
        options: {
          livereload: 35729
        },
      },
      sprite: {
        files: [basePaths.src+'/img/svg/*.svg'],
        tasks: ['sprite', 'css']
      },
      image: {
        files: [basePaths.src+'/images/*'],
        tasks: ['imagemin']
      },
      styles: {
        files: [basePaths.src+'/less/*'],
        tasks: ['css'],
        options: {
          livereload: 35729
        },
      },
    },

    connect: {
      server: {
        options: {
          livereload: 35729,
          port: 4040,
          protocol: 'http',
          hostname: 'localhost',
          base: ''
        },
        proxies: [
          {
            context: '/',
            host: 'localhost',
            port: 8080
          }
        ],
        livereload: {
                  options: {
                      middleware: function (connect) {
                          return [
                              proxySnippet
                          ];
                      }
                  }
              },
      }
    },

    notify: {
      options: {
        enabled: true,
        max_jshint_notifications: 5,
        success: false,
        duration: 3
      }
    }
  });

  
  require('load-grunt-tasks')(grunt);

  grunt.registerTask('init', ['clean', 'copy', 'sprite', 'imagemin', 'css']);
  grunt.registerTask('sprite', ['svg_sprite', 'svgmin', 'svg2png']);
  grunt.registerTask('css', ['concat:styles', 'less', 'postcss']);
  grunt.registerTask('javascript_dev', ['coffeeify', 'uglify:dev']);
  grunt.registerTask('javascript_build', ['coffeeify', 'babel', 'uglify:build']);

  grunt.registerTask('build', ['init', 'javascript_build', 'clean:after']);
  grunt.registerTask('default', ['init', 'javascript_dev', 'notify', 'connect', 'configureProxies:server', 'watch']);
}