<script lang="ts">
    import { authConfirmEmail } from "../api/authApi";
    import getAnalytics from "$lib/analytics";

    let payload: IAuthConfirmEmailRequest = {} as any;
    try {
      const encoded = document.location.hash.slice(1);
      document.location.hash = "";
      if (!encoded) {
          document.location = "/";
      }
      // Decode the base64 encoded string and parse it as JSON
      const decoded = decodeURIComponent(Array.prototype.map.call(window.atob(encoded), c => "%" + ("00" + c.charCodeAt(0).toString(16)).slice(-2)).join(""));
      payload = JSON.parse(decoded);
      if (!payload || !payload.code || !payload.email) {
        document.location = "/";
      }
      payload.analytics = JSON.stringify(getAnalytics());
      authConfirmEmail(payload).then(() => {
          document.location = "/";
      });
    } catch (e) {
        document.location = "/";
    }
</script>
<div class="min-h-screen bg-base-300 hero">
  <div class="loader-container">
    <div class="flex flex-col items-center justify-center space-y-6">
        <!-- Large Spinner -->
        <div class="loading loading-spinner text-primary w-32"></div>
        
        <!-- Text Message -->
        <h2 class="text-2xl font-semibol text-primary">Confirming Your Email</h2>
        <p class="text-warning">Please wait while we verify your email address...</p>
    </div>
  </div>
</div>

<style lang="scss">
</style>