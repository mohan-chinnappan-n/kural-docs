import { LightningElement, api } from 'lwc';

export default class KCarousel extends LightningElement {

    @api items = [

        {
          id: 1,
          img: 'https://lh3.googleusercontent.com/proxy/9jp879Er5Fs7h7a7AxhyC441UuBydIjFn-8LyUZ-k4DV9pKardd4iOhkolnRYIvT6tbnHvDS5aSlV-g14b_YixjC7uI8OgiV58A3R-ZS1KICONB8VNogQ5x-qwpjCTll4Try6uP2IB-MlQFbd24etXdn-XULgiXzLVWPkIJvVoK24Ik95ihOrBvGGsxXy5WGRDEeRgYxp6ve_61uYuD5Jas-INzIRGhuw3uXT-RBsspbst8=s1920-w1920-h1080-p-k-no-nd-mv',
          text: 'image text',
          current: true
        },
    
    
          {
          id: 2,
          img: 'https://lh6.googleusercontent.com/proxy/GJSBnfU2Ppf3LRVVTGaVkGGeHj8zS9E4TxrazbAa1mRN9fod89aum0Am0YT7OyAVYX1JF_reKm1_WuIhIy7iHT4Db_bKMwOeN8-Mk47FbuoVINWUwfpdczeycsl_cQXwkBw94zUSQOssXB-x_S7Z2I8fT-mHpz9SMbbe2bTzytn_R4LeIVjjLFIL6kVBReICQmbUCih-Zlgb8XoigYbrVE_JK6FWo3BFVBz4r-0qScH4OidrS6V93_DFdaynzzIZgA=s1920-w1920-h1080-p-k-no-nd-mv',
          text: 'image text',
          current: false
        },
    
          {
          id: 3,
          img: 'https://lh5.googleusercontent.com/proxy/wu5PLlVoRpgHMWz3tMImQqZvcSfDi9yLv_U0VcXS0ANV3j9egb3wbWjO1MO1Mt1FUOkU8f4g0k0vR-C7zRIH7ygVYCZbakKCjylzNV9qrz9TYCd_L2CHE_pYoK6S_vAKId2NiEadxzNcMNjXYY4-9T4jQvy1Cg7EWyKqfA4iAIknM3xSz8hCpk1vrL-Zk6DvgvsGCjlMIYwJEdlDWoaUR6HEb5eXbrnDHjyY-HGZIES8GHnYJi6Zi52XTxHFUnBNljxlggM=s1920-w1920-h1080-p-k-no-nd-mv',
          text: 'image text',
          current: false
        },
    
        {
          id: 4,
          img: 'https://lh6.googleusercontent.com/proxy/FtgmdiIeWl-LD-il97L0_fVAqntwZZXPoOFW4LSyEdULdene1G6ZxT4_BruPzO5-y4kBFwADONpmRaAUO_-NNPjFL605jgjFvwmk1s8ywiC7QQzG8zhySz0hcVSdi-NNmgV_6yEPXm3zcD8C9CGVAcf-U_HRAq9BuqXl-CNAf00VIceVZlnoFHDTNFfp_W2K2wmVmbm4RkygpA_3Mql_BbXgcxXr8p0dGmDy1eg-dyGKQ3kNRMFg=s1920-w1920-h1080-p-k-no-nd-mv',
          text: 'image text',
          current: false
        }
    
    
    
      ]
    
    
      async renderedCallback() {
    
        const track = this.template.querySelector('.carousel__track');
        const slides = Array.from( track.children);
    
        const nextButton = this.template.querySelector('.carousel__button--right');
        const prevButton =  this.template.querySelector('.carousel__button--left');
    
        const dotsNav = this.template.querySelector('.carousel__nav');
        const dots = Array.from( dotsNav.children);
        // console.log(dots.length);
    
        const slideWidth = slides[0].getBoundingClientRect().width;
    
        const setSlidePosition = (slide, index) => {
          slide.style.left = `${slideWidth * index}px`;
        }
    
        slides.forEach(setSlidePosition);
    
        const moveToSlide = (track, currentSlide, targetSlide) => {
    
          track.style.transform = `translateX(-${targetSlide.style.left})`;
    
          currentSlide.classList.remove('current-slide');
          targetSlide.classList.add('current-slide');
      
    
        }
    
        nextButton.addEventListener('click', e => {
          const currentSlide = track.querySelector('.current-slide');
    
          const nextSlide = currentSlide.nextElementSibling;
    
          const currentDot = dotsNav.querySelector('.current-slide');
          const nextDot = currentDot.nextElementSibling;
    
    
          moveToSlide(track, currentSlide, nextSlide);
          updateDots(currentDot, nextDot);
    
          const nextIndex = slides.findIndex( slide => slide === nextSlide);
          hideShowArrows(slides, prevButton, nextButton, nextIndex);
    
        });
    
        prevButton.addEventListener('click', e => {
          const currentSlide = track.querySelector('.current-slide');
    
          const prevSlide = currentSlide.previousElementSibling;
    
          moveToSlide(track, currentSlide, prevSlide);
    
          const currentDot = dotsNav.querySelector('.current-slide');
          const prevDot = currentDot.previousElementSibling;
          updateDots(currentDot, prevDot);
    
           const prevIndex = slides.findIndex( slide => slide === prevSlide);
          hideShowArrows(slides, prevButton, nextButton, prevIndex);
    
    
    
        });
    
        const updateDots = (currentDot, targetDot) => {
          currentDot.classList.remove('current-slide');
          targetDot.classList.add('current-slide');
    
        }
    
    
        const hideShowArrows = (slides,prevButton, nextButton,targetIndex) => {
    
          if (targetIndex === 0) {
              prevButton.classList.add('is-hidden');
              nextButton.classList.remove('is-hidden');
            } else if (targetIndex === slides.length - 1) {
              nextButton.classList.add('is-hidden');
              prevButton.classList.remove('is-hidden');
            } else {
              nextButton.classList.remove('is-hidden');
              prevButton.classList.remove('is-hidden');
            
            }
        }
    
    
        dotsNav.addEventListener('click', event => {
          const targetDot = event.target.closest('button');
          if (!targetDot) return;
          const currentSlide = track.querySelector('.current-slide');
          const currentDot = dotsNav.querySelector('.current-slide');
    
          const targetIndex = dots.findIndex( dot => dot === targetDot);
    
          const targetSlide = slides[targetIndex];
    
          moveToSlide(track, currentSlide, targetSlide);
    
          updateDots(currentDot, targetDot);
    
          hideShowArrows(slides, prevButton, nextButton, targetIndex);
          
        
    
        });
    
    
    
    
      }
}