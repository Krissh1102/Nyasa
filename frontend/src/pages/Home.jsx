import React, { useState } from "react";

import Hero from "../components/Hero";
import Marquee from "../components/Marquee";
import Collections from "../components/Collections";
import Shop from "../components/Shop";
import Craft from "../components/Craft";
import Process from "../components/Process";
import Testimonials from "../components/Testimonials";
import FAQ from "../components/FAQ";

export default function Home({ filter, setFilter, addToCart, cart = [], scrollTo }) {
  const [activeCollection, setActiveCollection] = useState("Rings");
  const [faqOpen, setFaqOpen] = useState(0);
  const [testimonialIdx, setTestimonialIdx] = useState(0);


  return (
    <>
      <Hero scrollTo={scrollTo} />
      <Marquee />
      <Collections
        activeCollection={activeCollection}
        setActiveCollection={setActiveCollection}
        setFilter={setFilter}
        scrollTo={scrollTo}
      />
      <Shop filter={filter} setFilter={setFilter} addToCart={addToCart} cart={cart} />
      <Craft />
      <Process />
      <Testimonials testimonialIdx={testimonialIdx} setTestimonialIdx={setTestimonialIdx} />
      <FAQ faqOpen={faqOpen} setFaqOpen={setFaqOpen} />

    </>
  );
}