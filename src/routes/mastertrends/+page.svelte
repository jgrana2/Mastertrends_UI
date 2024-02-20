<script lang="ts">
  import { onMount } from "svelte";
  import { writable } from "svelte/store";
  import { fade } from "svelte/transition";

  interface MasterTrend {
    _id?: {
      $oid: string;
    };
    masterTrends: Array<{
      category: string;
      trends: string[];
      _id: {
        $oid: string;
      };
    }>;
    topTrends: string[];
    timestamp: {
      $date: string;
    };
    __v?: number;
  }

  let last_item: MasterTrend = {
    masterTrends: [],
    topTrends: [],
    timestamp: {
      $date: new Date().toISOString(),
    },
  };

  let timestamp: string;

  async function getLastMasterTrend(): Promise<MasterTrend> {
    try {
      const response = await fetch("http://localhost:3003/getLastMasterTrend");
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      const data: MasterTrend = await response.json();
      last_item = data;
      timestamp = new Date(last_item.timestamp).toLocaleString("es-CO");
    } catch (error) {
      console.error(error);
    }
  }

  async function main() {
    try {
      await getLastMasterTrend();
    } catch (error) {
      console.error(error);
    }
  }

  onMount(async () => {
    main();
  });

  let isSaving = false;
  let isSaved = false;
  let saveResultMessage = "";
  let commentText = "";

  async function saveComment(comment: string): Promise<void> {
    if (isSaving) {
      return;
    }

    try {
      isSaving = true;
      const response = await fetch("http://localhost:3003/saveComment", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ comment }),
      });

      // Check if the response was successful based on the status code
      if (response.ok) {
        isSaved = true;
        // You may want to reset the state after some time or based on user interaction
        setTimeout(() => {
          isSaved = false;
          // Close the modal
          document.querySelector("[data-te-modal-dismiss]").click();
        }, 3000); // Reset the 'isSaved' state back to 'false' after 3 seconds
      } else {
        // Handle server response error
        throw new Error("Failed to save comment");
      }

      saveResultMessage = "Comment saved successfully!";
      console.log(saveResultMessage);
    } catch (error) {
      saveResultMessage = `Error: ${error.message}`;
      console.error(saveResultMessage);
    } finally {
      isSaving = false;
      commentText = "";
    }
  }

  const removeEmojis = (text) => {
    if (!text) {
      return "";
    }
    return text.replace(
      /([\u2700-\u27BF]|[\uE000-\uF8FF]|\uD83C[\uDC00-\uDFFF]|\uD83D[\uDC00-\uDFFF]|[\u2011-\u26FF]|\uD83E[\uDD10-\uDDFF])/g,
      "",
    );
  };
  const removeHashtags = (text) => {
    if (!text) {
      return "";
    }
    return text.replace(/#/g, "");
  };

  const cleanText = (text) => {
    const textWithoutEmojis = removeEmojis(text);
    const cleanedText = removeHashtags(textWithoutEmojis);
    return cleanedText;
  };

  const getUrl = (trend) => {
    // console.log(trend);
    let no_emoji_trend = removeEmojis(trend);
    // console.log(no_emoji_trend);
    // Remove emoji when searching
    return `https://news.google.com/search?q=${no_emoji_trend}&hl=es-419&gl=US&ceid=CO%3Aes-419`;
  };

  const buttonText = writable("Update Trends");
  let updating = false;
  let showUpdated = false;

  function updateTrends() {
    updating = true;
    showUpdated = false;
    console.log("Updating trends...");
    buttonText.set("Updating trends...");
    fetch("http://localhost:3003/updateTrends")
      .then((response) => response.json())
      .then(() => {
        updating = false;
        showUpdated = true;
        console.log("Trends updated.");
        setTimeout(() => {
          showUpdated = false;
          window.location.reload(true);
        }, 5000);
      })
      .catch((error) => {
        updating = false;
        console.log("Failed to update trends:", error);
        buttonText.set("Error updating trends");
      });
  }
</script>

<div class="rounded-lg shadow bg-base-200 mx-auto h-screen flex flex-col">
  <header class="flex justify-between items-center p-4">
    <div class="flex">
      <img src="mtlogo.png" alt="logo" class="pl-4 h-14" />
      <div class="font-mono dark:text-white text-lg font-bold items-center p-4">
        MASTERTRENDS
      </div>
    </div>
    <div class="flex gap-2 h-8">
      <button
        type="button"
        class="inline-flex justify-center items-center gap-2 rounded bg-primary px-6 pb-2 pt-2.5 text-xs font-medium uppercase leading-normal text-white shadow-[0_4px_9px_-4px_#3b71ca] transition duration-150 ease-in-out hover:bg-primary-600 hover:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)] focus:bg-primary-600 focus:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)] focus:outline-none focus:ring-0 active:bg-primary-700 active:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)] dark:shadow-[0_4px_9px_-4px_rgba(59,113,202,0.5)] dark:hover:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.2),0_4px_18px_0_rgba(59,113,202,0.1)] dark:focus:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.2),0_4px_18px_0_rgba(59,113,202,0.1)] dark:active:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.2),0_4px_18px_0_rgba(59,113,202,0.1)]"
        data-te-toggle="modal"
        data-te-target="#exampleModal"
        data-te-ripple-init
        data-te-ripple-color="light"
      >
        Feedback
      </button>
      <button
        on:click={updateTrends}
        type="button"
        class="inline-flex justify-center items-center gap-2 rounded bg-primary px-6 pb-2 pt-2.5 text-xs font-medium uppercase leading-normal text-white shadow-[0_4px_9px_-4px_#3b71ca] transition duration-150 ease-in-out hover:bg-primary-600 hover:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)] focus:bg-primary-600 focus:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)] focus:outline-none focus:ring-0 active:bg-primary-700 active:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)] dark:shadow-[0_4px_9px_-4px_rgba(59,113,202,0.5)] dark:hover:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.2),0_4px_18px_0_rgba(59,113,202,0.1)] dark:focus:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.2),0_4px_18px_0_rgba(59,113,202,0.1)] dark:active:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.2),0_4px_18px_0_rgba(59,113,202,0.1)]"
        data-te-ripple-init
      >
        {#if updating}
          <div
            class="inline-block h-4 w-4 animate-spin rounded-full border-4 border-solid border-current border-r-transparent align-middle motion-reduce:animate-[spin_1.5s_linear_infinite]"
            role="status"
          ></div>
        {/if}
        {#if showUpdated}
          <span transition:fade|out={{ duration: 2000 }}>Updated!</span>
        {:else}
          <span>{$buttonText}</span>
        {/if}
      </button>
    </div>
  </header>
  <div class="pl-7">
    <p>Última actualización: {timestamp}</p>
  </div>

  <!-- Trend cards container -->
  <div class="flex gap-2 p-4 pt-0 overflow-auto h-full">
    <div class="rounded-lg shadow-lg h-fit">
      <div class="p-4 whitespace-nowrap">
        <h2 class="text-xl font-bold mb-2 flex-col">Top Trends ⏫️</h2>
        <ul class="list-disc pl-4">
          {#each last_item.topTrends as trend}
            {#if trend.startsWith("#")}
              <li class="hover:underline">
                <a
                  href="https://twitter.com/hashtag/{cleanText(trend)}"
                  target="_blank">{trend}</a
                >
              </li>
            {:else}
              <li class="hover:underline">
                <a href={getUrl(trend)} target="_blank">{trend}</a>
              </li>
            {/if}
          {/each}
        </ul>
      </div>
    </div>
    {#each last_item.masterTrends as mtrend, index}
      <div class="w-fit">
        <div class="rounded-lg shadow-lg overflow-hidden">
          <div class="p-4 whitespace-nowrap">
            <h2 class="text-xl font-bold mb-2">
              {mtrend.category}
            </h2>
            <ul class="list-disc pl-4">
              {#each mtrend.trends as trend}
                {#if trend.startsWith("#")}
                  <li class="hover:underline">
                    <a
                      href="https://twitter.com/hashtag/{cleanText(trend)}"
                      target="_blank">{trend}</a
                    >
                  </li>
                {:else}
                  <li class="hover:underline">
                    <a href={getUrl(trend)} target="_blank">{trend}</a>
                  </li>
                {/if}
              {/each}
            </ul>
          </div>
        </div>
      </div>
    {/each}
    <!-- End Trend cards container -->
  </div>
</div>
<!-- Modal -->
<div
  data-te-modal-init
  class="fixed left-0 top-0 z-[1055] hidden h-full w-full overflow-y-auto overflow-x-hidden outline-none"
  id="exampleModal"
  tabindex="-1"
  aria-labelledby="exampleModalLabel"
  aria-hidden="true"
>
  <div
    data-te-modal-dialog-ref
    class="pointer-events-none relative w-auto translate-y-[-50px] opacity-0 transition-all duration-300 ease-in-out min-[576px]:mx-auto min-[576px]:mt-7 min-[576px]:max-w-[500px]"
  >
    <div
      class="min-[576px]:shadow-[0_0.5rem_1rem_rgba(#000, 0.15)] pointer-events-auto relative flex w-full flex-col rounded-md border-none bg-white bg-clip-padding text-current shadow-lg outline-none dark:bg-neutral-600"
    >
      <div
        class="flex flex-shrink-0 items-center justify-between rounded-t-md border-neutral-100 border-opacity-100 p-4 dark:border-opacity-50"
      >
        <!--Modal title-->
        <h5
          class="text-xl font-medium leading-normal text-neutral-800 dark:text-neutral-200"
          id="exampleModalLabel"
        >
          Enviar Comentarios
        </h5>
        <!--Close button-->
        <button
          type="button"
          class="box-content rounded-none border-none hover:no-underline hover:opacity-75 focus:opacity-100 focus:shadow-none focus:outline-none"
          data-te-modal-dismiss
          aria-label="Close"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="h-6 w-6"
          >
          </svg>
        </button>
      </div>

      <!--Modal body-->
      <div class="relative p-4" data-te-input-wrapper-init>
        <textarea
          id="commentTextarea"
          class="peer block min-h-[auto] w-full rounded border-0 bg-transparent px-3 py-[0.32rem] leading-[1.6] outline-none transition-all duration-200 ease-linear focus:placeholder:opacity-100 data-[te-input-state-active]:placeholder:opacity-100 motion-reduce:transition-none dark:text-neutral-200 dark:placeholder:text-neutral-200 [&:not([data-te-input-placeholder-active])]:placeholder:opacity-0"
          rows="3"
          placeholder="Your message"
          bind:value={commentText}
        />
        <label
          for="commentTextarea"
          class="pointer-events-none absolute left-4 top-0 mb-0 max-w-[90%] origin-[0_0] truncate pt-[0.37rem] leading-[1.6] transition-all duration-200 ease-out peer-focus:-translate-y-[0.9rem] peer-focus:scale-[0.8] peer-focus:text-primary peer-data-[te-input-state-active]:-translate-y-[0.9rem] peer-data-[te-input-state-active]:scale-[0.8] motion-reduce:transition-none dark:text-neutral-200 dark:peer-focus:text-primary"
          >Su comentario</label
        >
      </div>

      <!--Modal footer-->
      <div
        class="flex flex-shrink-0 flex-wrap items-center justify-end rounded-b-md pr-4 pb-4"
      >
        <button
          type="button"
          class="inline-block rounded bg-primary-100 px-6 pb-2 pt-2.5 text-xs font-medium uppercase leading-normal text-primary-700 transition duration-150 ease-in-out hover:bg-primary-accent-100 focus:bg-primary-accent-100 focus:outline-none focus:ring-0 active:bg-primary-accent-200"
          data-te-modal-dismiss
          data-te-ripple-init
          data-te-ripple-color="light"
        >
          Cancelar
        </button>
        <button
          type="button"
          on:click={() => {
            saveComment(commentText);
          }}
          class="ml-1 inline-block rounded bg-primary px-6 pb-2 pt-2.5 text-xs font-medium uppercase leading-normal text-white shadow-[0_4px_9px_-4px_#3b71ca] transition duration-150 ease-in-out hover:bg-primary-600 hover:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)] focus:bg-primary-600 focus:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)] focus:outline-none focus:ring-0 active:bg-primary-700 active:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)] dark:shadow-[0_4px_9px_-4px_rgba(59,113,202,0.5)] dark:hover:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.2),0_4px_18px_0_rgba(59,113,202,0.1)] dark:focus:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.2),0_4px_18px_0_rgba(59,113,202,0.1)] dark:active:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.2),0_4px_18px_0_rgba(59,113,202,0.1)]"
          data-te-ripple-init
          data-te-ripple-color="light"
          disabled={isSaving || isSaved}
        >
          {isSaving ? "Saving..." : isSaved ? "Saved" : "Enviar comentario"}
        </button>
      </div>
    </div>
  </div>
</div>
