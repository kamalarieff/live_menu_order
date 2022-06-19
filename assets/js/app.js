// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import { CountUp } from 'countup.js';
import Alpine from "alpinejs";
import { DragGesture } from '@use-gesture/vanilla';

window.Alpine = Alpine;

Alpine.data('cart', () => ({
  isOpen: false,
  init() {
    // gsap.from(this.$el, {
    //   y: '100%',
    //   duration: 0.7,
    //   opacity: 0
    // });

    const gesture = new DragGesture(this.$el, () => {
      if (this.isOpen == false ) {
        gsap.to(this.$el, {
          y: 100,
          ease: 'power1.inOut',
          duration: 0.3
        });

        // TODO: this looks better when there is a setTimeout
        this.$el.scrollTop = 0;
       
        this.isOpen = true;
      } else {
        gsap.to(this.$el, {
          y: window.innerHeight - 100,
          ease: 'power1.inOut',
          duration: 0.3
        });

        // TODO: this looks better when there is a setTimeout
        this.$el.scrollTop = 0;
       
        this.isOpen = false;
      }
    }, { axis: 'y', axisThreshold: 2 });
  },
}));

Alpine.start();

let Hooks = {};
Hooks.TotalNumber = {
  mounted() {
    let demo = new CountUp(this.el, this.el.dataset.total, {
      duration: 1,
      decimalPlaces: 2,
      prefix: 'RM ',
    });
    demo.start();

    this.handleEvent('update_state', e => {
      demo.update(e.total);
    });
  }
}

Hooks.LastAdded = {
  mounted() {
    this.handleEvent("update_state", () => {
      gsap.from(this.el, {
        y: 25,
        ease: 'power1.inOut',
        opacity: 0,
        duration: 0.3
      });
    });
  },
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  hooks: Hooks,
  dom: {
    onBeforeElUpdated(from, to) {
      if (from._x_dataStack) {
        window.Alpine.clone(from, to)
      }
    }
  }
});

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

