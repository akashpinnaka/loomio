class API::TranslationsController < API::RestfulController

  def show
    render json: translations_for(:en, params[:lang])
  end

  def inline
    self.resource = service.create(model: load_and_authorize(params[:model]), to: params[:to])
    respond_with_resource
  end

  private

  def translations_for(*locales)
    locales.map(&:to_s).uniq.reduce({}) do |translations, locale|
      locale = Loomio::I18n::FALLBACKS[locale]
      if File.exist?(yml_for(locale))
        translations.deep_merge(YAML.load_file(yml_for(locale))[locale])
                    .deep_merge(Plugins::Repository.translations_for(locale))
      else
        translations
      end
    end
  end

  def yml_for(locale)
    "config/locales/client.#{locale}.yml"
  end

end
