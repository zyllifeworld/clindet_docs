# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'Clindet'
copyright = '2024, Yuliang Zhang'
author = 'Yuliang Zhang'
release = '0.1.0'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

# extensions = [] 
extensions = [
    # 'recommonmark',
    "myst_nb",
    'sphinxcontrib.blockdiag',
    # "myst_parser",
    'sphinx_markdown_tables',
    'sphinx.ext.autosectionlabel',
    'sphinx_copybutton',
    'sphinx.ext.viewcode',
    'sphinx_togglebutton',
    "sphinx.ext.intersphinx",
    'sphinxcontrib.mermaid',
    "sphinx_copybutton",
    "sphinx_design",
    "sphinx_subfigure",
    ]

number_figures = True

numfig = True

numfig_secnum_depth = 1

numfig_format={'figure': '图%s', 'code-block': '程序清单%s', 'table': '表%s'}

autosectionlabel_prefix_document = True
source_suffix = {
    '.rst': 'restructuredtext',
    '.ipynb': 'myst-nb',
    '.myst': 'myst-nb',
    '.md': 'myst-nb',
    # '.md': 'markdown',
}


templates_path = ['_templates']
exclude_patterns = []



# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'alabaster'
html_static_path = ['_static']
html_css_files = ["custom.css"]
html_logo = "img/Clindet_logo.png"

import sphinx_book_theme
html_theme = "sphinx_book_theme"
html_theme_path = [sphinx_book_theme.get_html_theme_path()]

myst_substitutions = {
"rule_fontsize": "10pt"
}

mermaid_version = '11.4.0'
# 以下为 sphinx_book_theme 的主题配置/定制（sphinx_book_theme）
html_theme_options = {
    # "announcement": "Under development",
   # ----------------主题内容中导航栏的功能按钮配置--------
   # 添加存储库链接
#    "repository_url": "https://github.com/zyllifeworld/clindet",
   # 添加按钮以链接到存储库
#    "use_repository_button": True,
   # 要添加按钮以打开有关当前页面的问题
#    "use_issues_button": True,
#    # 添加一个按钮来建议编辑
#    "use_edit_page_button": True,
#    # 默认情况下，编辑按钮将指向master分支，但如果您想更改此设置，请使用以下配置
#    "repository_branch": "main",
#    # 默认情况下，编辑按钮将指向存储库的根目录；而我们 sphinx项目的 doc文件其实是在 source 文件夹下的，包括 conf.py 和 index(.rst) 主目录
#    "path_to_docs": "source",
#    # 您可以添加 use_download_button 按钮，允许用户以多种格式下载当前查看的页面
#    "use_download_button": True,

   # --------------------------右侧辅助栏配置---------
   # 重命名右侧边栏页内目录名，标题的默认值为Contents。
   "toc_title": "Contents",
   # 通常，右侧边栏页内目录中仅显示页面的第 2 级标题，只有当它们是活动部分的一部分时（在屏幕上滚动时），才会显示更深的级别。可以使用以下配置显示更深的级别，指示应显示多少级别
   "show_toc_level": 2,

   # --------------------------左侧边栏配置--------------
   # logo 配置
    "logo": {
      "text": "",
      "image_light": "img/Clindet_logo.png",
      "image_dark": "img/Clindet_logo.png",
   },
    # "navbar_start": ["navbar-logo"],
    # "navbar_center": ["navbar-nav"],
    # "navbar_end": ["navbar-icon-links"],
    # "navbar_persistent": ["search-button"],
   # 控制左侧边栏列表的深度展开,默认值为1，它仅显示文档的顶级部分
    # "show_navbar_depth": 2,
   # 自定义侧边栏页脚,默认为 Theme by the Executable Book Project
   # "extra_navbar": "<p>Your HTML</p>",
    "home_page_in_toc": True,
    "max_navbar_depth": 4,
    "content_footer_items": ["last-updated"],
   # ------------------------- 单页模式 -----------------
   # 如果您的文档只有一个页面，并且您不需要左侧导航栏，那么您可以 使用以下配置将其配置sphinx-book-theme 为以单页模式运行
   # "single_page": True,
}


myst_enable_extensions = [
    # 用于解析美元$和$$封装的数学和LaTeX 数学公式解析
    "dollarmath","amsmath",
    # 定义列表
    "deflist",
    # 冒号的代码围栏
    "colon_fence",
    # HTML 警告
    "html_admonition",
    # HTML 图像
    "html_image",
    # 智能引号与替换件
    "smartquotes","replacements",
    # 链接
    "linkify",
    # 替换
    "substitution",
    # 任务列表
    "tasklist"
]