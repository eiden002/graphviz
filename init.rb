Redmine::Plugin.register :graphviz do
  name 'Graphviz plugin for Redmine'
  author 'Yoshiaki Tanaka'
  description 'This is a plugin for Redmine which renders Graphviz diagrams.'
  version '0.0.1'
  url 'https://github.com/wate/redmine_graphviz'

  requires_redmine version: '2.6'..'3.4'

  settings(partial: 'settings/graphviz',
           default: { 'graphviz_binary' => {}, 'cache_seconds' => '0', 'allow_includes' => false })

  Redmine::WikiFormatting::Macros.register do
    desc <<EOF
      Render Graphviz image.
      <pre>
      {{graphviz(png)
      digraph G {
        未対応 -> 対応中 -> 対応済み -> 完了;
        未対応 -> 破棄;
        対応済み -> フィードバック;
        フィードバック -> 対応中;
        フィードバック -> 対応済み;
      }
      }}
      </pre>

      Available options are:
      ** (png|svg)
EOF
    macro :graphviz do |obj, args, text|
      raise 'No Graphviz binary set.' if Setting.plugin_graphviz['graphviz_binary_default'].blank?
      raise 'No or bad arguments.' if args.size != 1
      frmt = GraphvizHelper.check_format(args.first)
      image = GraphvizHelper.graphviz(text, args.first)
      image_tag "/graphviz/#{frmt[:type]}/#{image}#{frmt[:ext]}"
    end
  end
end

Rails.configuration.to_prepare do
  # Guards against including the module multiple time (like in tests)
  # and registering multiple callbacks

  unless Redmine::WikiFormatting::Textile::Helper.included_modules.include? GraphvizHelperPatch
    Redmine::WikiFormatting::Textile::Helper.send(:include, GraphvizHelperPatch)
  end
end
