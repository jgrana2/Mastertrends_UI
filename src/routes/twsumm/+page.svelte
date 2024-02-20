<script lang="ts">
  import ContentBlock from "./ContentBlock.svelte";

  interface TWSummary {
    index: number;
    title: string;
    points: string[];
    timestamp?: string;
    loading: boolean;
  }

  let inputValue = "";
  let customBlocks: TWSummary[] = [];
  let currentIndex = 0;
  let element: any;

  async function getTWSummary(q: string, value: string): Promise<TWSummary> {
    const newBlock: TWSummary = {
      index: currentIndex++,
      title: value,
      points: [],
      loading: true,
    };
    addBlock(newBlock);
    inputValue = "";

    try {
      const response = await fetch(
        `http://192.168.1.4:3004/getTWSummary?${q}=${value}`
      );
      const data = await response.json();
      updateBlock(newBlock.index, data);
      console.log(customBlocks);
    } catch (error) {
      console.log(error);
      // Handle error
    }
  }

  function addBlock(data: TWSummary) {
    customBlocks = [...customBlocks, data];
    scrollToBottom();
  }

  function updateBlock(index: number, data: TWSummary) {
    const updatedBlocks = customBlocks.map((block) => {
      if (block.index === index) {
        block = { ...block, ...data, loading: false };
      }
      return block;
    });
    customBlocks = updatedBlocks;
    scrollToBottom();
  }

  function scrollToBottom() {
    console.log("Scrolling...");
    let myElement: HTMLElement | null = document.getElementById(
      "scrollable-container"
    );
    if (myElement !== null) {
      console.log(myElement);
      myElement.scrollTo({ top: myElement.scrollHeight });
      myElement.scrollIntoView(false);
    } else {
      console.log("Element is null");
    }
  }
</script>

<div class="flex h-screen container mx-auto antialiased bg-base-200">
  <div class="flex flex-col flex-auto flex-shrink-0 rounded w-full">
    <div class="flex flex-col h-full overflow-y-auto" id="scrollable-container">
      <div class="flex flex-col">
        {#each customBlocks as { index, title, points, timestamp, loading }}
          <ContentBlock {title} {points} {timestamp} {loading} {index} />
        {/each}
      </div>
    </div>
    <div class="flex flex-row items-center rounded w-full p-2">
      <div class="flex-grow">
        <div class="relative w-full">
          <input
            bind:value={inputValue}
            type="text"
            class="flex w-full rounded-l-lg h-10 border-0 dark:bg-base-100 dark:text-white"
            on:keydown={(e) => {
              if (e.key === "Enter") {
                getTWSummary("q", inputValue);
                inputValue = "";
              }
            }}
          />
        </div>
      </div>
      <div class="">
        <button
          on:click={() => {
            getTWSummary("q", inputValue);
            inputValue = "";
          }}
          class="flex items-center justify-center dark:bg-gray-700 bg-gray-200 hover:bg-indigo-300 dark:hover:bg-indigo-800 rounded-r-lg dark:text-white p-4 flex-shrink-0 h-10"
        >
          <span class="ml-1 mb-1">
            <svg
              class="w-4 h-4 transform rotate-45 -mt-px"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"
              />
            </svg>
          </span>
        </button>
      </div>
    </div>
  </div>
</div>

<style>
  @supports (-webkit-touch-callout: none) {
    .h-screen {
      height: -webkit-fill-available;
    }
  }
</style>
