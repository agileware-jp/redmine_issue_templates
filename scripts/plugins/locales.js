export const LocalePlugin = {
  install(Vue, locale) {
    Vue.prototype.l = (key) => {
      return locale[key];
    };
  }
};
