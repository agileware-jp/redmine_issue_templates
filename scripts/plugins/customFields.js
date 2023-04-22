import axios from 'axios';

export const CustomFieldPlugin = {
  install(Vue, options = {}) {
    const {
      baseUrl,
      templateId,
      projectId,
    } = options;
    Vue.prototype.getCustomFields = async (trackerId) => {
      const params = {
        tracker_id: trackerId,
        template_id: templateId,
        project_id: projectId,
      };
      const { data } = await axios.get(baseUrl, { params });
      const { custom_fields } = data;
      return custom_fields;
    };
  }
};
