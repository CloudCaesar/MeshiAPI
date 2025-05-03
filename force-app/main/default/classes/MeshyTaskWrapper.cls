public with sharing class MeshyTaskWrapper {
    @AuraEnabled public String id { get; set; }
    @AuraEnabled public String mode { get; set; }
    @AuraEnabled public String name { get; set; }
    @AuraEnabled public Long seed { get; set; }
    @AuraEnabled public String art_style { get; set; }
    @AuraEnabled public String texture_richness { get; set; }
    @AuraEnabled public String prompt { get; set; }
    @AuraEnabled public String negative_prompt { get; set; }
    @AuraEnabled public String texture_prompt { get; set; }
    @AuraEnabled public String texture_image_url { get; set; }
    @AuraEnabled public String status { get; set; }
    @AuraEnabled public Long created_at { get; set; }
    @AuraEnabled public Integer progress { get; set; }
    @AuraEnabled public Long started_at { get; set; }
    @AuraEnabled public Long finished_at { get; set; }
    @AuraEnabled public String task_error { get; set; }
    @AuraEnabled public ModelUrlsWrapper model_urls { get; set; }
    @AuraEnabled public String thumbnail_url { get; set; }
    @AuraEnabled public String video_url { get; set; }
    @AuraEnabled public List<TextureUrlWrapper> texture_urls { get; set; }

    // Subclass for model URLs
    public class ModelUrlsWrapper {
        @AuraEnabled public String glb { get; set; }
        @AuraEnabled public String fbx { get; set; }
        @AuraEnabled public String usdz { get; set; }
        @AuraEnabled public String obj { get; set; }
        @AuraEnabled public String mtl { get; set; }
    }

    // Subclass for texture URLs
    public class TextureUrlWrapper {
        @AuraEnabled public String base_color { get; set; }
    }

    // Subclass for Meshy API balance response
    public class MeshyBalanceWrapper {
        @AuraEnabled public Integer credits { get; set; }
        @AuraEnabled public Integer used_credits { get; set; }
        @AuraEnabled public Integer remaining_credits { get; set; }
        @AuraEnabled public Long last_updated { get; set; }
    }

    // Subclass for Image-to-3D task creation response
    public class ImageTo3DTaskResponse {
        @AuraEnabled public String taskId { get; set; }
        @AuraEnabled public String error { get; set; }
    }

    // Method to parse JSON string into a list of MeshyTaskWrapper objects
    public static List<MeshyTaskWrapper> parse(String jsonString) {
        return (List<MeshyTaskWrapper>) JSON.deserialize(jsonString, List<MeshyTaskWrapper>.class);
    }

    // Method to parse JSON string into a MeshyBalanceWrapper object
    public static MeshyTaskWrapper.MeshyBalanceWrapper parseBalance(String jsonString) {
        Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        Map<String, Object> result = (Map<String, Object>) jsonResponse.get('result');
        return (MeshyTaskWrapper.MeshyBalanceWrapper) JSON.deserialize(JSON.serialize(result), MeshyTaskWrapper.MeshyBalanceWrapper.class);
    }

    // Method to parse JSON string into an ImageTo3DTaskResponse object
    public static MeshyTaskWrapper.ImageTo3DTaskResponse parseImageTo3DTaskResponse(String jsonString) {
        MeshyTaskWrapper.ImageTo3DTaskResponse response = new MeshyTaskWrapper.ImageTo3DTaskResponse();
        try {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            response.taskId = (String) jsonResponse.get('result');
            if (String.isBlank(response.taskId)) {
                response.error = 'Invalid response: No task ID returned.';
            }
        } catch (Exception e) {
            response.error = 'Parsing error: ' + e.getMessage();
        }
        return response;
    }
}